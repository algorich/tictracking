class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_latests_projects

  layout :layout_by_resource

  def set_latests_projects
    if current_user
      @latests_projects = current_user.projects.order('updated_at DESC').first(3)
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  def layout_by_resource
    if devise_controller?
      'login'
    else
      'application'
    end
  end
end