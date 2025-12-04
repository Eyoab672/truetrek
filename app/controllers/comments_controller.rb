require "open-uri"

class CommentsController < ApplicationController
  SYSTEM_PROMPT = <<~PROMPT.freeze
    You are a helpful travel assistant that provides concise, engaging summaries about places.
    When enhancing descriptions, keep them informative but brief (2-3 paragraphs max).
    Use the Wikipedia tool when you need factual information about a place.
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
      enhance_description_with_comment if @comment.valid?
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

    # Step 1: Generate initial summary
    step1 = @chat.ask("Write a brief summary about #{@place.title}.")
    @place.original_description = step1.content

    # Step 2: Enhance with Wikipedia data (conversation continues)
    step2 = @chat.ask("Now use the Wikipedia tool to get factual information about #{@place.title} and enhance the summary.")
    @place.enhanced_description = step2.content
  rescue StandardError => e
    Rails.logger.error("Failed to generate place descriptions: #{e.message}")
  end

  def enhance_description_with_comment
    return if @place.enhanced_description.blank?

    @chat = RubyLLM.chat
    @chat.with_instructions(SYSTEM_PROMPT)

    # Build conversation history from existing description
    @chat.ask("Here is the current description of #{@place.title}: #{@place.enhanced_description}")

    # Enhance with new comment
    response = @chat.ask(
      "A visitor shared this experience: '#{@comment.description}'. " \
      "Update the description to incorporate relevant insights from their visit, keeping it concise."
    )

    @place.update(enhanced_description: response.content)
  rescue StandardError => e
    Rails.logger.error("Failed to enhance description: #{e.message}")
  end
end
