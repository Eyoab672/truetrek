class UpdateEnhancedDescriptionJob < ApplicationJob
  queue_as :default

  ENHANCEMENT_PROMPT = <<~PROMPT.freeze
    You are a helpful travel assistant that provides concise, engaging summaries about places.
    Create informative but brief descriptions (3-4 paragraphs max).
    Incorporate visitor experiences naturally into the description.
    IMPORTANT: Give significantly more weight to insights from LOCAL residents, as they have
    deeper knowledge of the place. Local insights should be prominently featured.
  PROMPT

  def perform(place_id)
    place = Place.find_by(id: place_id)
    return unless place

    all_comments = place.comments.includes(:votes, :user)
    regenerate_description(place, all_comments)

    # Broadcast the updated description via Turbo Streams
    broadcast_description(place)
  rescue StandardError => e
    Rails.logger.error("UpdateEnhancedDescriptionJob failed for place #{place_id}: #{e.message}")
    Rails.logger.error(e.backtrace.first(10).join("\n"))
    # Still broadcast the current description (even if unchanged) to remove loading state
    broadcast_description(place) if place
  end

  private

  def broadcast_description(place)
    Turbo::StreamsChannel.broadcast_replace_to(
      "place_#{place.id}",
      target: "place_description",
      partial: "places/description",
      locals: { place: place.reload }
    )
  end

  def regenerate_description(place, all_comments)
    # Rank comments: positives first, locals boosted; take top 3 overall.
    top_comments = all_comments.sort_by { |c| c.ordering_key(local_bonus: 2) }.first(3)

    # If no comments, revert to original description
    if top_comments.empty?
      place.update(enhanced_description: place.original_description)
      return
    end

    chat = RubyLLM.chat
    chat.with_instructions(ENHANCEMENT_PROMPT)

    local_experiences = top_comments.select(&:user_is_local?)
    visitor_experiences = top_comments.reject(&:user_is_local?)

    sections = []
    if local_experiences.any?
      local_texts = local_experiences.map { |c| format_experience(c) }
      sections << "LOCAL INSIGHTS (from residents - HIGH PRIORITY):\n#{local_texts.join("\n\n")}"
    end

    if visitor_experiences.any?
      visitor_texts = visitor_experiences.map { |c| format_experience(c) }
      sections << "VISITOR EXPERIENCES:\n#{visitor_texts.join("\n\n")}"
    end

    prompt = <<~MSG
      Here is the base description of #{place.title}:
      #{place.original_description}

      Here are the top community experiences (ranked by votes with a local bonus). Each experience already ends with the contributor's username in parentheses—keep that format in the final description:
      #{sections.join("\n\n")}

      Please create an enhanced description (3-4 paragraphs) that incorporates these experiences naturally.
      Prioritize and highlight insights from LOCAL residents as they have authentic knowledge.

      CRITICAL REQUIREMENTS:
      1. You MUST incorporate ALL of the community experiences provided above into the final description.
      2. Each experience MUST appear as a complete sentence or clause ending with " (username)" where username is the exact lowercase username provided.
      3. Do NOT skip any experiences—all #{top_comments.size} experiences must be included.
      4. Example format: "The courtyard felt peaceful (john_doe)."
      5. Do NOT mention usernames anywhere else in the text—only append them at the end of sentences containing their experiences.
    MSG

    response = chat.ask(prompt)
    place.update(enhanced_description: response.content)
  end

  def format_experience(comment)
    prefix = comment.user_is_local? ? "[LOCAL] " : ""
    username = (comment.user&.username || 'visitor').downcase
    "#{prefix}#{comment.description} (#{username})"
  end
end
