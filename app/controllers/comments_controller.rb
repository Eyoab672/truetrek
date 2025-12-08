require "open-uri"

class CommentsController < ApplicationController
  SYSTEM_PROMPT = <<~PROMPT.freeze
    You are a helpful travel assistant that provides concise, engaging summaries about places.
    Keep descriptions informative but brief (2-3 paragraphs max).

    You MAY use the Wikipedia tool for factual details, but if it fails or returns no useful results:
    - Do NOT mention the failure and do NOT include phrases like "couldn't find" or "no results".
    - Instead, synthesize from what the visitor wrote, the address/location, the city/region, and general travel knowledge.
    - Always return a polished description without tool errors or apologies.
  PROMPT

  def new
    @comment = Comment.new
    @place = Place.new
    authorize @comment
  end

  def create
    if params[:place_id]
      # Flow 2: Adding comment to existing place (nested route)
      @place = Place.find(params[:place_id])
      @comment = build_comment
    else
      # Flow 1: Creating new place with first comment
      @place = Place.new(place_params)
      generate_place_descriptions
      unless @place.save
        render :new, status: :unprocessable_entity
        return
      end
      @comment = build_comment
    end

    authorize @comment

    if @comment.save
      UpdateEnhancedDescriptionJob.perform_later(@place.id)
      redirect_to city_place_path(@place.city, @place)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    @place = @comment.place
    authorize @comment

    @comment.destroy

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove("comment_#{@comment.id}") }
      format.html { redirect_to city_place_path(@place.city, @place), notice: "Comment deleted." }
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:description, photos: [])
  end

  def place_params
    params.require(:place).permit(:title, :city_id, :latitude, :longitude, :address)
  end

  def build_comment
    comment = Comment.new(comment_params)
    comment.place = @place
    comment.user = current_user
    comment
  end

  def generate_place_descriptions
    @chat = RubyLLM.chat
    @chat.with_instructions(SYSTEM_PROMPT)
    @chat.with_tool(WikipediaTool.new)

    user_review = params.dig(:comment, :description).presence || "Visitor review not provided yet."
    address = @place.address.presence
    city = @place.city&.name
    location_context = [address, city].compact_blank.join(", ")

    # Get the username of the comment author
    username = current_user&.username || "anonymous"

    base_subject = location_context.present? ? "#{@place.title} located around #{location_context}" : @place.title

    # Step 1: Generate initial summary
    step1 = @chat.ask("Write a brief summary about #{base_subject}.")
    @place.original_description = step1.content

    # Step 2: Enhance with Wikipedia data (conversation continues)
    step2_prompt = <<~MSG
      Enhance the summary using available sources.
      - Try the Wikipedia tool for factual information about #{@place.title}.
      - Also incorporate this visitor review: "#{user_review}"
      - Location context: #{location_context.presence || 'Unknown'}

      IMPORTANT: When including content from the visitor review, end that sentence with " (#{username.downcase})" in parentheses.
      Example format: "The place was peaceful and historic (username)."
      Do NOT mention the username anywhere else in the text—only append it at the end of the sentence containing the review.
      If Wikipedia returns nothing useful, still produce a polished description using the review and location context without mentioning any tool errors.
    MSG

    step2 = @chat.ask(step2_prompt)
    @place.enhanced_description = step2.content

    # Fallback: detect and remove any Wikipedia failure phrasing
    if contains_wikipedia_failure?(@place.enhanced_description)
      fallback_prompt = <<~MSG
        Rewrite the description without mentioning Wikipedia or any tool issues.
        Use the visitor review and the location context to craft an engaging, concise description.
        Visitor review: "#{user_review}"
        Location context: #{location_context.presence || 'Unknown'}
        IMPORTANT: When including content from the visitor review, end that sentence with " (#{username.downcase})" in parentheses.
        Example format: "The place was peaceful and historic (username)."
        Do NOT mention the username anywhere else in the text—only append it at the end of the sentence containing the review.
      MSG

      fallback = @chat.ask(fallback_prompt)
      @place.enhanced_description = fallback.content
    end
  rescue StandardError => e
    Rails.logger.error("Failed to generate place descriptions: #{e.message}")
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
