class ProjectsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    @projects = current_user.projects
  end

  def show
    @project = Project.find(params[:id])
    @tasks = @project.tasks.order('updated_at DESC')
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
    @project = Project.new(params[:project])
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
      if @project.update_attributes(params[:project])
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
    user = User.find(params[:user_id])
    if @project.can_add? user
      @project.users << user
      UserMailer.mail_add_user(user, @project).deliver
      params[:message] = { type: 'success', text: 'User was added to this project' }
    else
      params[:message] = { type: 'error', text: 'User already in this project' }
    end
    render 'update_team'
  end

  def report
    @project = Project.find(params[:id])
    @begin_at = @project.created_at
    @end_at = Time.now
    @users = @project.users
    @users.reject! { |user| user.observer?(@project) }
    @values = {
      user_id: nil,
      begin_at: nil,
      end_at: nil
    }
  end

  def filter
    #TODO: test de controller
    @project = Project.find(params[:id])
    @begin_at = params[:filter][:begin_at].to_time || @project.created_at
    @end_at = params[:filter][:end_at].to_time || Time.now
    @users = @project.users
    @user_filtered = @users.find_by_id(params[:filter][:user_id])
    @values = {
      user_id: params[:filter][:user_id],
      begin_at: params[:filter][:begin_at],
      end_at: params[:filter][:end_at]
    }
    @users = [@user_filtered] if !@user_filtered.nil?
    render 'report'
  end
end
