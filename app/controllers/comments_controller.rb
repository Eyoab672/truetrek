class CommentsController < ApplicationController
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
      unless @place.save
        render :new, status: :unprocessable_entity
        return
      end
    end

    @comment = Comment.new(comment_params)
    @comment.place = @place
    @comment.user = current_user

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
end
