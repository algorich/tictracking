module TaskHelper
  def play_or_stop_task(task)
    result = ''

    if current_user.exists_pending_worktimes? task
      hide_play = 'hide'
    else
      hide_stop = 'hide'
    end

    result += remote_button(label: '<i class="icon-play"></i>',
      url: task_worktimes_path(task),
      hide: hide_play,
      method: 'POST')

    unless current_user.worktimes.where(task_id: task).empty?
      worktime = task.worktimes.where(user_id: current_user).last

      result += remote_button(label: '<i class="icon-stop"></i>',
        url: stop_task_worktime_path(task, worktime),
        hide: hide_stop,
        method: 'PUT')
    end

    result.html_safe
  end

  private

  def remote_button(label: label, url: url, hide: nil, method: method)
    content_tag(:button, label.html_safe,
      class: "btn #{hide} app-btn-loading app-remote-button",
      data: { url: url, method: method })
  end
end
