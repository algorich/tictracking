class SiteController < ApplicationController
  before_filter :authenticate_user!, only: [:dashboard]

  def index
  end

  def dashboard
    @tasks = current_user.latest_tasks(3)
  end
end