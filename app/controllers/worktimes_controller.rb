class WorktimesController < ApplicationController
  def create
    @worktime = Worktime.new(
      begin: Time.now,
      user_id: current_user.id,
      task_id: params[:worktime][:task_id])

    if @worktime.save
      redirect_to project_path(params[:worktime][:project_id]),
       notice: 'Successfully'
    else
      redirect_to project_path(params[:worktime][:project_id]),
       notice: "Can't be created"
    end
  end
end