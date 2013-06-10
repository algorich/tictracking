class TasksController < ApplicationController
  before_filter :authenticate_user!

  def create
    @task = Task.new(params[:task])

    if @task.save
      Worktime.create(begin: Time.now, user_id: current_user.id, task_id: @task.id)
      redirect_to project_path(@task.project_id), notice: 'Successfully created'
    else
      flash[:error] = "Task can't be created"
      redirect_to project_path @task.project_id
    end
  end

  def edit
    @task = Task.find(params[:id])
  end

  def update
    @task = Task.find(params[:id])
    @task.update_attributes(params[:task])
    flash[:notice] = 'Update successfully'
    redirect_to project_path @task.project_id
  end

  def destroy
    @task = Task.find(params[:id])
    Task.destroy(params[:id])
    flash[:notice] = 'Delete successfully'
    redirect_to project_path @task.project_id
  end
end