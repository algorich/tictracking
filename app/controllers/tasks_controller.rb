class TasksController < ApplicationController
  before_filter :authenticate_user!

  def create
    @task = Task.new(params[:task])

    if @task.save
      Worktime.create!(begin: Time.now, user_id: current_user.id, task_id: @task.id)
      redirect_to project_path(@task.project_id), notice: 'Successfully created'
    else
      flash[:error] = "Task can't be created"
      redirect_to project_path(@task.project_id)
    end
  end

  def edit
    @task = Task.find(params[:id])
  end

  def update
    # TODO: where is the error case?
    @task = Task.find(params[:id])
    @task.update_attributes(params[:task])
    redirect_to project_path(@task.project_id), notice: 'Update successfully'
  end

  def destroy
    @task = Task.find(params[:id])
    Task.destroy(params[:id])
    redirect_to project_path(@task.project_id), notice: 'Delete successfully'
  end
end