class VotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_comment

  def create
    new_value = vote_params[:value].to_i

    @comment.with_lock do
      existing_vote = @comment.votes.find_by(user: current_user)

      if existing_vote
        # Any click on vote buttons removes the existing vote (toggle off or cancel opposite)
        @vote = existing_vote
        authorize @vote, :destroy?
        @vote.destroy
      else
        # No existing vote, create a new one
        @vote = @comment.votes.build(user: current_user, value: new_value)
        authorize @vote, :create?
        @vote.save
      end
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
    place = @comment.place
    # Broadcast loading state immediately
    Turbo::StreamsChannel.broadcast_replace_to(
      "place_#{place.id}",
      target: "place_description",
      partial: "places/description_loading",
      locals: { place: place }
    )
    # Then queue the job to generate the new description
    UpdateEnhancedDescriptionJob.perform_later(place.id)
  end
end
