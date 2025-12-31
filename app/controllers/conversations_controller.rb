class ConversationsController < ApplicationController
  before_action :set_conversation, only: [:show, :accept, :decline, :leave, :add_members, :remove_member, :update, :info]

  def index
    @conversations = policy_scope(Conversation)
      .for_user(current_user)
      .where("conversations.accepted = ? OR conversations.is_group = ?", true, true)
      .includes(:sender, :recipient, :messages, :active_members)
      .order(updated_at: :desc)
    @requests = current_user.received_conversations.pending.where(is_group: false).includes(:sender, :messages)
    authorize Conversation
  end

  def show
    authorize @conversation
    @messages = @conversation.messages.chronological.includes(:user, photos_attachments: :blob)

    if @conversation.group?
      @members = @conversation.active_members.includes(avatar_attachment: :blob)
    else
      @other_user = @conversation.other_user(current_user)
    end

    # Mark messages as read
    @conversation.messages.where.not(user: current_user).where(read_at: nil).update_all(read_at: Time.current)
  end

  def new
    @conversation = Conversation.new
    authorize @conversation
    @users = User.where.not(id: current_user.id).order(:username)
  end

  def create
    authorize Conversation

    if params[:is_group] == "true" || params[:member_ids].present?
      create_group
    else
      create_dm
    end
  end

  def create_group
    member_ids = params[:member_ids] || []
    member_ids = member_ids.reject(&:blank?).map(&:to_i)

    if member_ids.size < 2
      redirect_to new_conversation_path, alert: "Please select at least 2 members for a group chat"
      return
    end

    @conversation = Conversation.create_group(
      creator: current_user,
      member_ids: member_ids,
      name: params[:group_name].presence
    )

    if @conversation.persisted?
      redirect_to @conversation, notice: "Group created successfully"
    else
      redirect_to new_conversation_path, alert: @conversation.errors.full_messages.join(", ")
    end
  end

  def create_dm
    @recipient = User.find(params[:recipient_id])
    @conversation = Conversation.find_or_create_dm(current_user, @recipient)

    redirect_to @conversation
  rescue ActiveRecord::RecordNotFound
    redirect_to conversations_path, alert: "User not found"
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

  def info
    authorize @conversation
    @members = @conversation.active_members.includes(:conversation_members, avatar_attachment: :blob)

    # Shared media
    @media_messages = @conversation.messages.joins(:photos_attachments).distinct.order(created_at: :desc).limit(50)
    @video_messages = @conversation.messages.joins(:videos_attachments).distinct.order(created_at: :desc).limit(50)
    @voice_messages = @conversation.messages.joins(:voice_message_attachment).distinct.order(created_at: :desc).limit(50)

    # Extract links from message bodies
    @link_messages = @conversation.messages.where("body LIKE '%http%'").order(created_at: :desc).limit(50)
  end

  def update
    authorize @conversation

    if @conversation.update(group_params)
      redirect_to @conversation, notice: "Group updated successfully"
    else
      redirect_to info_conversation_path(@conversation), alert: @conversation.errors.full_messages.join(", ")
    end
  end

  def add_members
    authorize @conversation

    unless @conversation.is_admin?(current_user)
      redirect_to @conversation, alert: "Only admins can add members"
      return
    end

    member_ids = params[:member_ids] || []
    member_ids = member_ids.reject(&:blank?).map(&:to_i)

    added_count = 0
    User.where(id: member_ids).find_each do |user|
      if @conversation.add_member(user)
        added_count += 1
      end
    end

    redirect_to info_conversation_path(@conversation),
                notice: "#{added_count} member(s) added"
  end

  def remove_member
    authorize @conversation

    user_to_remove = User.find(params[:user_id])

    # Only admins can remove others, anyone can remove themselves
    unless @conversation.is_admin?(current_user) || user_to_remove == current_user
      redirect_to @conversation, alert: "Only admins can remove members"
      return
    end

    @conversation.remove_member(user_to_remove)

    if user_to_remove == current_user
      redirect_to conversations_path, notice: "You left the group"
    else
      redirect_to info_conversation_path(@conversation), notice: "#{user_to_remove.username} removed from group"
    end
  end

  def leave
    authorize @conversation

    @conversation.remove_member(current_user)
    redirect_to conversations_path, notice: "You left the group"
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:id])
  end

  def group_params
    params.require(:conversation).permit(:group_name, :group_avatar)
  end
end
