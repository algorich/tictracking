class SiteController < ApplicationController
  before_filter :authenticate_user!, only: [:dashboard]

  def index
  end

  def dashboard
    @tasks = current_user.latest(3, :tasks)
    @projects = current_user.latest(3, :projects)
  end
end