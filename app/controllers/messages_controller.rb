class MessagesController < ApplicationController
  before_action :set_conversation
  before_action :set_message, only: [:destroy]

  def create
    @message = @conversation.messages.build(message_params)
    @message.user = current_user
    authorize @message

    unless @conversation.can_send_message?(current_user)
      redirect_to @conversation, alert: "You cannot send messages until your request is accepted"
      return
    end

    if @message.save
      # Auto-accept if mutual follow (for first message)
      @conversation.auto_accept_if_mutual!
      @conversation.touch # Update conversation timestamp

      respond_to do |format|
        format.html { redirect_to @conversation }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { redirect_to @conversation, alert: @message.errors.full_messages.join(", ") }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("message_form", partial: "messages/form", locals: { conversation: @conversation, message: @message }) }
      end
    end
  end

  def destroy
    authorize @message

    if @message.can_unsend?
      @message.destroy
      respond_to do |format|
        format.html { redirect_to @conversation, notice: "Message unsent" }
        format.turbo_stream
      end
    else
      redirect_to @conversation, alert: "You can only unsend messages within 48 hours"
    end
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:conversation_id])
  end

  def set_message
    @message = @conversation.messages.find(params[:id])
  end

  def message_params
    params.require(:message).permit(:body, :replied_to_message_id, :voice_message, photos: [], videos: [])
  end
end
