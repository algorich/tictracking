class WorktimesController < ApplicationController
  def create
    if params[:commit] == 'Continue'
      if Worktime.last.end != nil

        @worktime = Worktime.new(begin: Time.now, user_id: current_user.id,
         task_id: params[:worktime][:task_id ])

          if @worktime.save
            redirect_to project_path(params[:worktime][:project_id]),
             notice: 'Successfully'
          else
            redirect_to project_path(params[:worktime][:project_id]),
             notice: "Can't be created"
          end

      else
        redirect_to project_path(params[:worktime][:project_id]), alert:
        'Should stop worktime'
      end
    else
      @worktime = Worktime.last.update_attribute(:end, Time.now)
      redirect_to project_path(params[:worktime][:project_id]), notice:'Deleted'
    end
  end
end