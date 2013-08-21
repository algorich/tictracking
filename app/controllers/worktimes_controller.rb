class WorktimesController < ApplicationController
  load_and_authorize_resource
  skip_authorize_resource :only => :create

  after_filter :destroy_flash, only: [:stop, :create]

  def create
    @task = Task.find(params[:task_id])
    @worktime = Worktime.new(task: @task, beginning: Time.now, user_id: current_user.id)
    authorize! :create, @worktime
    @worktime.save
    params[:message] = { type: 'error', text: @worktime.errors[:base].try(:first) }
  end

  def edit
    @task = Task.find(params[:task_id])
    @worktime = Worktime.find(params[:id])
  end

  def stop
    @task = Task.find(params[:task_id])
    @worktime = Worktime.find(params[:id])
    @worktime.update_attributes(finish: Time.now)
    flash[:error] = @worktime.errors[:base].try(:first)
  end

  def update
    @task = Task.find(params[:task_id])
    @worktime = Worktime.find(params[:id])
    @worktime.skip_stopped_validation = true

    if @worktime.update_attributes(params[:worktime])
      redirect_to project_path(@task.project_id), notice: "Worktime updated with success."
     else
      redirect_to edit_task_worktime_path(@task, @worktime)
      flash[:error] = @worktime.errors[:base].try(:first)
    end
  end

  def destroy
    task = Task.find(params[:task_id])
    Worktime.destroy(params[:id])
    redirect_to project_path(task.project_id), notice: 'Deleted'
  end

  private

  def destroy_flash
    flash.delete(:error)
  end
end