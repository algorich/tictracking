class TasksController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def create
    @task = Task.new(params[:task])
    @project = Project.where(project_id: @task.project_id)
    if @task.save
      Worktime.create(beginning: Time.now, user_id: current_user.id, task_id: @task.id)
    else
      params[:message] = { type: 'error', text: @task.errors[:name].try(:first) }
    end
  end

  def edit
    @task = Task.find(params[:id])
  end

  def update
    @task = Task.find(params[:id])

    if @task.update_attributes(params[:task])
      redirect_to project_path(@task.project_id), notice: 'Update successfully'
    else
      render action: 'edit'
    end
  end

  def destroy
    @task = Task.find(params[:id])
    Task.destroy(params[:id])
    redirect_to project_path(@task.project_id), notice: 'Delete successfully'
  end

  private

  def task_params
    params.require(:task).permit(:name, :project, :project_id)
  end
end