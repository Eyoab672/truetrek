require "open-uri"

class CommentsController < ApplicationController
  SYSTEM_PROMPT = "You are a helpful assistant that provides concise Wikipedia summaries about places. When asked about a place, use the wikipedia tool to fetch information and return a brief 2-3 sentence summary."

  def new
    @comment = Comment.new
    @place = Place.new
    authorize @comment
  end

  def create
    if params[:place_id]
      # Flow 2: Adding comment to existing place (nested route)
      @place = Place.find(params[:place_id])
    else
      # Flow 1: Creating new place with first comment
      @place = Place.new(place_params)
      @place.wiki_description = fetch_wiki_description(@place.title)
      unless @place.save
        render :new, status: :unprocessable_entity
        return
      end
    end

    @comment = Comment.new(comment_params)
    @comment.place = @place
    @comment.user = current_user
    authorize @comment

    if @comment.save
      redirect_to city_place_path(@place.city, @place)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:description, photos: [])
  end

  def place_params
    params.require(:place).permit(:title, :city_id, :latitude, :longitude, :address)
  end

  def fetch_wiki_description(place_name, model: "gpt-4.1-nano")
    return nil if place_name.blank?

    chat = RubyLLM.chat(model: model)
    chat.with_tool(WikipediaTool.new)
    chat.with_instructions(SYSTEM_PROMPT)

    response = chat.ask("Get me a summary about #{place_name}")
    response.content
  rescue StandardError => e
    Rails.logger.error("Failed to fetch wiki description: #{e.message}")
    nil
  end
end
