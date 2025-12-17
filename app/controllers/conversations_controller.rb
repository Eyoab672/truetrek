class ConversationsController < ApplicationController
  before_action :set_conversation, only: [:show, :accept, :decline]

  def index
    @conversations = policy_scope(Conversation)
      .accepted
      .includes(:sender, :recipient, :messages)
      .order(updated_at: :desc)
    @requests = current_user.received_conversations.pending.includes(:sender, :messages)
    authorize Conversation
  end

  def show
    authorize @conversation
    @messages = @conversation.messages.chronological.includes(:user, photos_attachments: :blob)
    @other_user = @conversation.other_user(current_user)

    # Mark messages as read
    @conversation.messages.where.not(user: current_user).where(read_at: nil).update_all(read_at: Time.current)
  end

  def create
    @recipient = User.find(params[:recipient_id])
    @conversation = current_user.conversation_with(@recipient) ||
                    current_user.sent_conversations.build(recipient: @recipient)

    authorize @conversation

    if @conversation.new_record?
      # Auto-accept if mutual follow
      @conversation.accepted = @conversation.mutual_follow?
      @conversation.accepted_at = Time.current if @conversation.accepted?

      if @conversation.save
        redirect_to @conversation
      else
        redirect_to user_path(@recipient), alert: @conversation.errors.full_messages.join(", ")
      end
    else
      redirect_to @conversation
    end
  end

  def accept
    authorize @conversation
    @conversation.accept!

    respond_to do |format|
      format.html { redirect_to @conversation, notice: "Message request accepted" }
      format.turbo_stream
    end
  end

  def decline
    authorize @conversation
    @conversation.destroy

    respond_to do |format|
      format.html { redirect_to conversations_path, notice: "Message request declined" }
      format.turbo_stream
    end
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:id])
  end
end
