class RepliesController < ApplicationController
  def create
    @parent_comment = Comment.find(params[:comment_id])
    @place = @parent_comment.place

    @reply = Comment.new(reply_params)
    @reply.parent = @parent_comment
    @reply.place = @place
    @reply.user = current_user
    authorize @reply, policy_class: CommentPolicy

    if @reply.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to city_place_path(@place.city, @place) }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("reply_form_#{@parent_comment.id}", partial: "replies/form", locals: { comment: @parent_comment, reply: @reply }) }
        format.html { redirect_to city_place_path(@place.city, @place), alert: "Could not post reply." }
      end
    end
  end

  private

  def reply_params
    params.require(:comment).permit(:description)
  end
end
