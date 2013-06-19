class SiteController < ApplicationController
  before_filter :authenticate_user!, only: [:dashboard]

  def index
  end

  def dashboard
    @projects = current_user.projects.order('updated_at DESC').first(3)
    @tasks = current_user.latest_tasks(3)
  end
end