class GeneratePlaceDescriptionJob < ApplicationJob
  queue_as :default

  SYSTEM_PROMPT = <<~PROMPT.freeze
    You are a helpful travel assistant that provides concise, engaging summaries about places.
    Keep descriptions informative but brief (2-3 paragraphs max).

    You MAY use the Wikipedia tool for factual details, but if it fails or returns no useful results:
    - Do NOT mention the failure and do NOT include phrases like "couldn't find" or "no results".
    - Instead, synthesize from what the visitor wrote, the address/location, the city/region, and general travel knowledge.
    - Always return a polished description without tool errors or apologies.
  PROMPT

  def perform(place_id, user_review:, username:)
    place = Place.find_by(id: place_id)
    return unless place

    generate_descriptions(place, user_review, username)

    # Broadcast the updated description to the place's show page
    Turbo::StreamsChannel.broadcast_replace_to(
      "place_#{place.id}",
      target: "place_description",
      partial: "places/description",
      locals: { place: place }
    )
  rescue StandardError => e
    Rails.logger.error("GeneratePlaceDescriptionJob failed for place #{place_id}: #{e.message}")
    # Broadcast error state
    Turbo::StreamsChannel.broadcast_replace_to(
      "place_#{place.id}",
      target: "place_description",
      partial: "places/description_error",
      locals: { place: place }
    )
  end

  private

  def generate_descriptions(place, user_review, username)
    chat = RubyLLM.chat
    chat.with_instructions(SYSTEM_PROMPT)
    chat.with_tool(WikipediaTool.new)

    address = place.address.presence
    city = place.city&.name
    location_context = [address, city].compact_blank.join(", ")

    base_subject = location_context.present? ? "#{place.title} located around #{location_context}" : place.title

    # Step 1: Generate initial summary
    step1 = chat.ask("Write a brief summary about #{base_subject}.")
    place.update(original_description: step1.content)

    # Step 2: Enhance with Wikipedia data
    step2_prompt = <<~MSG
      Enhance the summary using available sources.
      - Try the Wikipedia tool for factual information about #{place.title}.
      - Also incorporate this visitor review: "#{user_review}"
      - Location context: #{location_context.presence || 'Unknown'}

      IMPORTANT: When including content from the visitor review, end that sentence with " (#{username.downcase})" in parentheses.
      Example format: "The place was peaceful and historic (username)."
      Do NOT mention the username anywhere else in the text—only append it at the end of the sentence containing the review.
      If Wikipedia returns nothing useful, still produce a polished description using the review and location context without mentioning any tool errors.
    MSG

    step2 = chat.ask(step2_prompt)
    enhanced = step2.content

    # Fallback: detect and remove any Wikipedia failure phrasing
    if contains_wikipedia_failure?(enhanced)
      fallback_prompt = <<~MSG
        Rewrite the description without mentioning Wikipedia or any tool issues.
        Use the visitor review and the location context to craft an engaging, concise description.
        Visitor review: "#{user_review}"
        Location context: #{location_context.presence || 'Unknown'}
        IMPORTANT: When including content from the visitor review, end that sentence with " (#{username.downcase})" in parentheses.
        Example format: "The place was peaceful and historic (username)."
        Do NOT mention the username anywhere else in the text—only append it at the end of the sentence containing the review.
      MSG

      fallback = chat.ask(fallback_prompt)
      enhanced = fallback.content
    end

    place.update(enhanced_description: enhanced)
  end

  def contains_wikipedia_failure?(text)
    return false if text.blank?

    failure_indicators = [
      "couldn't find", "could not find", "unable to find", "no results", "wikipedia", "error", "failed to", "not available"
    ]

    downcased = text.downcase
    failure_indicators.any? { |indicator| downcased.include?(indicator) }
  end
end
