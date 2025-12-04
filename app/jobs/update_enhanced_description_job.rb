class UpdateEnhancedDescriptionJob < ApplicationJob
  queue_as :default

  ENHANCEMENT_PROMPT = <<~PROMPT.freeze
    You are a helpful travel assistant that provides concise, engaging summaries about places.
    Create informative but brief descriptions (2-3 paragraphs max).
    Incorporate visitor experiences naturally into the description.
  PROMPT

  def perform(place_id)
    place = Place.find_by(id: place_id)
    return unless place

    all_comments = place.comments.includes(:votes, :user)
    positive_comments = all_comments.where(parent_id: nil).select(&:positive_vote_balance?)
    positive_replies = all_comments.where.not(parent_id: nil).select(&:positive_vote_balance?)

    if positive_comments.empty? && positive_replies.empty?
      place.update(enhanced_description: place.original_description)
      return
    end

    regenerate_description(place, positive_comments, positive_replies)
  rescue StandardError => e
    Rails.logger.error("UpdateEnhancedDescriptionJob failed for place #{place_id}: #{e.message}")
  end

  private

  def regenerate_description(place, positive_comments, positive_replies)
    chat = RubyLLM.chat
    chat.with_instructions(ENHANCEMENT_PROMPT)

    experiences = []

    if positive_comments.any?
      comment_texts = positive_comments.map do |comment|
        "#{comment.user&.username || 'A visitor'}: '#{comment.description}'"
      end
      experiences << "Main reviews:\n#{comment_texts.join("\n\n")}"
    end

    if positive_replies.any?
      reply_texts = positive_replies.map do |reply|
        "#{reply.user&.username || 'A visitor'}: '#{reply.description}'"
      end
      experiences << "Additional insights from replies:\n#{reply_texts.join("\n\n")}"
    end

    prompt = <<~MSG
      Here is the base description of #{place.title}:
      #{place.original_description}

      Here are verified visitor experiences (comments and replies with positive community votes):
      #{experiences.join("\n\n")}

      Please create an enhanced description that incorporates these visitor experiences naturally.
      Keep it concise (2-3 paragraphs max).
    MSG

    response = chat.ask(prompt)
    place.update(enhanced_description: response.content)
  end
end
