module ApplicationHelper
  def format_description_with_avatars(description, place)
    return '' if description.blank?

    # Get all users who commented on this place
    users_by_username = place.comments.includes(:user).map(&:user).compact.index_by { |u| u.username.downcase }

    # Replace (username) with avatar + username
    description.gsub(/\(([a-z0-9_]+)\)/) do |match|
      username = ::Regexp.last_match(1)
      user = users_by_username[username]

      if user
        avatar_html = if user.avatar.attached? && user.avatar.blob&.persisted?
                        image_tag(url_for(user.avatar), alt: user.username, class: "inline-avatar")
                      else
                        content_tag(:span, user.username.first.upcase, class: "inline-avatar-placeholder")
                      end

        content_tag(:span, class: "username-reference") do
          avatar_html + content_tag(:span, "#{user.username}", class: "username-text")
        end
      else
        match # Keep original if user not found
      end
    end.html_safe
  end
end
