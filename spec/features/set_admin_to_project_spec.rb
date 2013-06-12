require 'spec_helper'

feature 'Set admin(s) to project' do
  scenario 'should have a check box to set the admins on project#show', js:true do
    user = create(:user_confirmed)
    project = create(:project, users: [user])
    login_as user

    visit project_path(project)
    user_box = find("#user-#{user.id}")
    expect(user_box).not_to be_checked

    check("user-#{user.id}")

    visit project_path(project)
    user_box = find("#user-#{user.id}")
    expect(user_box).to be_checked
  end
end