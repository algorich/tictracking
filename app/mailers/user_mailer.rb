class UserMailer < ActionMailer::Base
  default from: "from@example.com"

  def mail_add_user(user, project)
    @user = user
    @project = project

    mail to: user.email , subject: 'Add in Project'
  end
end
