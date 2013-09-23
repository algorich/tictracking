class ApplicationController < ActionController::Base
  protect_from_forgery

  layout :layout_by_resource

  before_filter :set_latests_projects

  before_filter :configure_permitted_parameters, if: :devise_controller?

  #for cancan in rails 4
  before_filter do
    resource = controller_path.singularize.gsub('/', '_').to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

  def set_latests_projects
    if current_user
      @latests_projects = current_user.projects.order('updated_at DESC').first(3)
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

  protected

  def layout_by_resource
    devise_controller? ? 'login' : 'application'
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:account_update) << :name
    devise_parameter_sanitizer.for(:sign_up) << :name
  end
end