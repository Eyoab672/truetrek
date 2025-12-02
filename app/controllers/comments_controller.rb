class CommentsController < ApplicationController

  def new
    @comment = Comment.new
  end
  
  def create
    @comment = Comment.new(comment_params)
    @place = Place.create
    @comment.place = @place
    @comment.user = current_user

    if @comment.save!
      redirect_to city_place_path(@place)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:description)
  end
end
