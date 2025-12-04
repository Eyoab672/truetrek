module DescriptionEnhancer
  extend ActiveSupport::Concern

  ENHANCEMENT_PROMPT = <<~PROMPT.freeze
    You are a helpful travel assistant that provides concise, engaging summaries about places.
    When enhancing descriptions, keep them informative but brief (2-3 paragraphs max).
    Incorporate visitor experiences naturally into the description.
  PROMPT

  private

  def enhance_description_with_content(place, content, author_name = "A visitor")
    return if place.enhanced_description.blank? || content.blank?

    chat = RubyLLM.chat
    chat.with_instructions(ENHANCEMENT_PROMPT)

    # Provide current description as context
    chat.ask("Here is the current description of #{place.title}: #{place.enhanced_description}")

    # Enhance with new content
    response = chat.ask(
      "#{author_name} shared this experience: '#{content}'. " \
      "Update the description to incorporate relevant insights from their visit, keeping it concise."
    )

    place.update(enhanced_description: response.content)
  rescue StandardError => e
    Rails.logger.error("Failed to enhance description: #{e.message}")
  end
end
