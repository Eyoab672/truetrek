module ApplicationHelper
  def format_description_with_avatars(description, place)
    return '' if description.blank?

    # Get all comments (including replies) for this place
    all_comments = place.comments.includes(:user)
    users_by_username = all_comments.map(&:user).compact.index_by { |u| u.username.downcase }

    # Replace (username) with avatar + username link
    description.gsub(/\(([a-z0-9_]+)\)/) do |match|
      username = ::Regexp.last_match(1)
      user = users_by_username[username]

      if user
        # Find the most relevant comment from this user (highest voted, most recent)
        user_comment = all_comments
          .select { |c| c.user_id == user.id }
          .max_by { |c| [c.vote_balance, c.created_at] }

        if user_comment
          avatar_html = if user.avatar.attached? && user.avatar.blob&.persisted?
                          image_tag(url_for(user.avatar), alt: user.username, class: "inline-avatar")
                        else
                          content_tag(:span, user.username.first.upcase, class: "inline-avatar-placeholder")
                        end

          link_to "#comment_#{user_comment.id}", class: "username-reference-link" do
            content_tag(:span, class: "username-reference") do
              avatar_html + content_tag(:span, "@#{user.username}", class: "username-text")
            end
          end
        else
          match
        end
      else
        match # Keep original if user not found
      end
    end.html_safe
  end
end
