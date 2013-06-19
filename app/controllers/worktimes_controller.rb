class WorktimesController < ApplicationController
  load_and_authorize_resource

  def create
    if params[:commit] == 'Continue'
      if Worktime.last.end != nil

        @worktime = Worktime.new(begin: Time.now, user_id: current_user.id,
         task_id: params[:worktime][:task_id ])

          if @worktime.save
            redirect_to project_path(@worktime.task.project_id),
             notice: 'Successfully'
          else
            redirect_to project_path(@worktime.task.project_id),
             notice: "Can't be created"
          end

      else
        redirect_to project_path(@worktime.task.project_id), alert:
        'Should stop worktime'
      end
    else
      @worktime = Worktime.last
      @worktime.update_attributes(end: Time.now)
      redirect_to project_path(@worktime.task.project_id), notice:'Stopped'
    end
  end

  def edit
    @task = Task.find(params[:task_id])
    @worktime = Worktime.find(params[:id])
  end

  def update
    task = Task.find(params[:task_id])
    @worktime = Worktime.find(params[:id])

    if @worktime.update_attributes(params[:worktime])
      redirect_to project_path(task.project_id), notice: "Worktime updated "
     else
      render edit_task_worktime_path(task, @worktime)
    end
  end

  def destroy
    task = Task.find(params[:task_id])
    Worktime.destroy(params[:id])

    redirect_to project_path(task.project_id), notice: 'Deleted'
  end

end