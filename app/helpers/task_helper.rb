module TaskHelper
  def play_or_stop_task(task)
    result = ''

    if current_user.exists_pending_worktimes? task
      hide_stop, hide_play = '', 'hide'
    else
      hide_stop, hide_play = 'hide', ''
    end

    result += link_to task_worktimes_path(task),
      { method: :post, remote: true, class: "btn #{hide_play}" } do
        '<i class="icon-play"></i>'.html_safe
    end

    unless current_user.worktimes.where(task_id: task).empty?
      worktime = task.worktimes.where(user_id: current_user).last

      result += link_to stop_task_worktime_path(task, worktime),
        { method: :put, remote: true, class: "btn #{hide_stop}" } do
          '<i class="icon-stop"></i>'.html_safe
      end
    end

    result.html_safe
  end
end
