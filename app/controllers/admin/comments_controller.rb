module Admin
  class CommentsController < BaseController
    before_action :set_comment, only: [:show, :destroy]

    def index
      @comments = Comment.includes(:user, :place, place: :city)
                         .where(parent_id: nil)
                         .order(created_at: :desc)

      if params[:query].present?
        @comments = @comments.search(params[:query])
      end

      if params[:user_id].present?
        @comments = @comments.where(user_id: params[:user_id])
      end
    end

    def show
      @place = @comment.place
      @user = @comment.user
      @replies = @comment.replies.includes(:user).order(created_at: :asc)
    end

    def destroy
      place = @comment.place
      @comment.destroy

      UpdateEnhancedDescriptionJob.perform_later(place.id)

      respond_to do |format|
        format.html { redirect_to admin_comments_path, notice: "Comment deleted successfully." }
        format.turbo_stream { render turbo_stream: turbo_stream.remove("admin_comment_#{@comment.id}") }
      end
    end

    private

    def set_comment
      @comment = Comment.find(params[:id])
    end
  end
end
