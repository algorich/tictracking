module ApplicationHelper
  def avatar_url(user)
    gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
    "http://gravatar.com/avatar/#{gravatar_id}.png?s=48"
  end

  def app_flash_message
    content_tag(:div,
      content_tag(:button, raw('&times;'), :class => 'close', 'data-dismiss' => 'alert') +
      content_tag(:span, 'message'),
      :class => 'alert fade in hide',
      :id => 'app_flash_message').html_safe
  end

  def user_info(user)
    image_tag(avatar_url(user), alt: user.name, size: '30x30',
      class: 'img-rounded pull-left') +
    content_tag(:span,
      content_tag(:strong, user.email) + '<br />'.html_safe +
      content_tag(:small, user.try(:name)),
      class: 'text-account in-team')
  end
end
