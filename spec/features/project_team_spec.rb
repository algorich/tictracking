require 'spec_helper'

feature 'Project team' do
  context 'Set admin(s) to project', js:true do
    scenario 'should have a check box to set the admins on project#team' do
      user_1 = create(:user_confirmed)
      user_2 = create(:user_confirmed)
      project = create(:project, users: [user_1])
      membership = create(:membership, project: project, user: user_2, admin: false)
      login_as user_1
      visit team_project_path(project)
      user_1_box = find("#user-#{user_1.id}")
      user_2_box = find("#user-#{user_2.id}")
      expect(user_1_box).to be_checked
      expect(user_2_box).not_to be_checked

      check("user-#{user_2.id}")

      visit team_project_path(project)
      user_1_box = find("#user-#{user_1.id}")
      user_2_box = find("#user-#{user_2.id}")
      expect(user_2_box).to be_checked
      expect(user_1_box).to be_checked
    end

    scenario 'project should have at least one admin' do
      project = create(:project)
      user = project.memberships.first.user

      login_as user
      visit team_project_path(project)
      user_box = find("#user-#{user.id}")

      uncheck("user-#{user.id}")
      expect(page).to have_content('Project should have at least one admin!')
      expect(user_box).to be_checked
    end
  end

  scenario 'show team' do
    user_1 = create(:user_confirmed)
    user_2 = create(:user_confirmed)
    project = create(:project, users: [user_1])
    membership = create(:membership, project: project, user: user_2, admin: false)
    login_as user_2

    visit team_project_path(project)
    user_1_box = find("#user-#{user_1.id}")
    user_2_box = find("#user-#{user_2.id}")
    expect(user_1_box).to be_checked
    expect(user_2_box).not_to be_checked

    expect(user_1_box).to be_disabled
    expect(user_2_box).to be_disabled
  end
end