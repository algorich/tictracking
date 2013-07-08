class WorktimesController < ApplicationController
  load_and_authorize_resource
  skip_authorize_resource :only => :create

  def create
    @task = Task.find(params[:task_id])
    @worktime = Worktime.new(task: @task, begin: Time.now, user_id: current_user.id)
    authorize! :create, @worktime
    @worktime.save
  end

  def edit
    @task = Task.find(params[:task_id])
    @worktime = Worktime.find(params[:id])
  end

  def update
    if params[:commit] == 'Update Worktime'
      @task = Task.find(params[:task_id])
      @worktime = Worktime.find(params[:id])
      if @worktime.update_attributes(params[:worktime])
        redirect_to project_path(@task.project_id)
      end
    else
      @task = Task.find(params[:task_id])
      @worktime = Worktime.find(params[:id])
      @worktime.end = Time.now
      if @worktime.save

      else
        render edit_task_worktime_path(task, @worktime)
      end
    end
  end

  def destroy
    task = Task.find(params[:task_id])
    Worktime.destroy(params[:id])
    redirect_to project_path(task.project_id), notice: 'Deleted'
  end

end