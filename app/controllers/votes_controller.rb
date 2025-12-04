class VotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_comment

  def create
    @vote = @comment.votes.find_or_initialize_by(user: current_user)
    new_value = vote_params[:value].to_i

    # If clicking the same vote button, remove the vote (toggle off)
    if @vote.persisted? && @vote.value == new_value
      authorize @vote, :destroy?
      @vote.destroy
    else
      @vote.value = new_value
      authorize @vote
      @vote.save
    end

    update_enhanced_description
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to city_place_path(@comment.place.city, @comment.place) }
    end
  end

  def destroy
    @vote = @comment.votes.find_by(user: current_user)
    authorize @vote

    if @vote&.destroy
      update_enhanced_description
      respond_to do |format|
        format.turbo_stream { render :create }
        format.html { redirect_to city_place_path(@comment.place.city, @comment.place) }
      end
    else
      redirect_to city_place_path(@comment.place.city, @comment.place)
    end
  end

  private

  def set_comment
    @comment = Comment.find(params[:comment_id])
  end

  def vote_params
    params.require(:vote).permit(:value)
  end

  def update_enhanced_description
    UpdateEnhancedDescriptionJob.perform_later(@comment.place_id)
  end
end
