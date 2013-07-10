class WorktimesController < ApplicationController
  load_and_authorize_resource
  skip_authorize_resource :only => :create

  respond_to :html, :json

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

  def stop
    @task = Task.find(params[:task_id])
    @worktime = Worktime.find(params[:id])
    @worktime.end = Time.now
    @worktime.save
  end

  def update
    @worktime = Worktime.find(params[:id])
    @worktime.update_attributes(params[:worktime])
    respond_with @worktime
  end

  def destroy
    task = Task.find(params[:task_id])
    Worktime.destroy(params[:id])
    redirect_to project_path(task.project_id), notice: 'Deleted'
  end

end