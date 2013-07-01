class TasksController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def create
    @task = Task.new(params[:task])

    if @task.save
      Worktime.create!(begin: Time.now, user_id: current_user.id, task_id: @task.id)
      redirect_to project_path(@task.project_id), notice: 'Successfully created'
    else
      flash[:alert] = "Task can't be created"
      redirect_to project_path(@task.project_id)
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
end