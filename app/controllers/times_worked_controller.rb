class TimesWorkedController < ApplicationController
  before_filter :authenticate_user!

  def index
    @projects = current_user.projects
  end

  def admin
    @projects = current_user.projects.select { |project| current_user.admin? project  }
  end
end
