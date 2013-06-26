module ApplicationHelper
  def avatar_url(user)
    gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
    "http://gravatar.com/avatar/#{gravatar_id}.png?s=48"
  end

  def flash_message
    unless flash.present?
      content_tag(:div,
        content_tag(:button, raw("&times;"), :class => "close", "data-dismiss" => "alert") +
        content_tag(:span, 'message'), :class => "alert fade in alert-success hide")
    else
      bootstrap_flash
    end
  end
end
