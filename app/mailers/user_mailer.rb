class UserMailer < ActionMailer::Base
  default from: 'no-reply@tictracking.com'

  def mail_add_user(user, project)
    @user = user
    @project = project

    mail to: user.email , subject: 'You have been added to a project at TicTracking'
  end
end
