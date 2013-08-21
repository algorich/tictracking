module TaskHelper
  def play_or_stop_task(task)
    result = ''

    if current_user.exists_pending_worktimes? task
      hide_stop, hide_play = '', 'hide'
    else
      hide_stop, hide_play = 'hide', ''
    end

    result += link_to task_worktimes_path(task),
      { method: :post, remote: true, class: "btn #{hide_play} app-btn-loading" } do
        '<i class="icon-play"></i>'.html_safe
    end

    unless current_user.worktimes.where(task_id: task).empty?
      worktime = task.worktimes.where(user_id: current_user).last

      result += content_tag(:button, '<i class="icon-stop"></i>'.html_safe,
        class: "btn #{hide_stop} app-btn-loading app-remote-button",
        data: { url: stop_task_worktime_path(task, worktime)})
    end

    result.html_safe
  end
end
