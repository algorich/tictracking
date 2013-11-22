class ProjectsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    @projects = current_user.projects
  end

  def show
    @project = Project.find(params[:id])
    @tasks = @project.tasks.order('updated_at DESC').page(params[:page]).per(10)
    @worktime = Worktime.new
    @task = Task.new(project: @project)

    respond_to do |format|
      format.html
      format.json { render json: @project }
    end
  end

  def new
    @project = Project.new

    respond_to do |format|
      format.html
      format.json { render json: @project }
    end
  end

  def edit
    @project = Project.find(params[:id])
  end

  def create
    @project = Project.new(project_params)
    @project.set_admin(current_user)

    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render json: @project, status: :created, location: @project }
      else
        format.html { render action: "new" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @project = Project.find(params[:id])

    respond_to do |format|
      if @project.update_attributes(project_params)
        format.html { redirect_to @project, notice: 'Project was successfully update.' }
      else
        format.html { render action: "edit" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @project = Project.find(params[:id])
    @project.destroy

    respond_to do |format|
      format.html { redirect_to projects_url }
      format.json { head :no_content }
    end
  end

  def change_role
    project = Project.find(params[:id])
    membership = project.memberships.find(params[:membership_id])
    role = params[:role]

    if membership.set_role!(role)
      user = membership.user
      indentification = user.name || user.email
      render json: { success: true, message: "Change the #{indentification}'s role with success!" }
    else
      render json: { success: false, message: 'Project should have at least one admin!'}
    end
  end

  def team
    @project = Project.find(params[:id])
    @users = @project.users
  end

  def add_user
    @project = Project.find(params[:id])
    user = User.find_by_id(params[:user_id])
    if @project.can_add?(user)
      @project.memberships.create(user: user, role: params[:user_role])
      UserMailer.mail_add_user(user, @project).deliver
      params[:message] = { type: 'success', text: 'User was added to this project' }
    else
      params[:message] = { type: 'error', text: @project.errors[:user].first.html_safe }
    end
    render 'update_team'
  end

  def report
    @project = Project.find(params[:id])
    @begin_at = Time.now.beginning_of_day
    @end_at = Time.now
    @users = @project.users.joins(:memberships).where.not(memberships: {role: 'observer'}).distinct

    @users_with_filtered_tasks = @project.filter(users: @users, begin_at: @begin_at, end_at: @end_at)

    @values = {
      user_id: nil,
      begin_at: l(@begin_at, format: :datetimepicker),
      end_at: l(@end_at, format: :datetimepicker)
    }
  end

  def filter
    #TODO: test de controller
    @project = Project.find(params[:id])
    @begin_at = params[:filter][:begin_at].to_time || @project.created_at
    @end_at = params[:filter][:end_at].to_time || Time.now

    @values = {
      user_ids: params[:filter][:user_ids],
      begin_at: params[:filter][:begin_at],
      end_at: params[:filter][:end_at]
    }

    @users_filtered = @project.users.where(id: params[:filter][:user_ids])
    @users = @users_filtered.present? ? @users_filtered : @project.users

    @users_with_filtered_tasks = @project.filter(users: @users, begin_at: @begin_at, end_at: @end_at)
    render 'report'
  end

  private

  def project_params
    params.require(:project).permit(:name)
  end
end
