class ProjectsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    @projects = current_user.projects
  end

  def show
    @project = Project.find(params[:id])
    @tasks = @project.tasks
    @worktime = Worktime.new
    @task = Task.new

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
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { head :no_content }
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

  def change_admin
    project = Project.find(params[:id])
    membership = project.memberships.where(user_id: params[:admin_id]).first
    if membership.toggle_admin!
      render json: { success: true }
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
    #TODO: passar logica para model
    @project.users << user if !@project.users.include? user
    respond_to :js
  end
end
