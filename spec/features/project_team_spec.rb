require 'spec_helper'

feature 'Project team' do
  context 'Set admin(s) to project', js:true do
    scenario 'should have a check box to set the admins on project#team' do
      user_1 = create(:user_confirmed)
      user_2 = create(:user_confirmed)
      user_3 = create(:user_confirmed)
      project = create(:project, users: [user_1]) #project's admin
      create(:membership, project: project, user: user_2, admin: false)
      membership_3 = create(:membership, project: project, user: user_3, admin: false)

      login_as user_1
      visit edit_project_path(project)
      click_link 'Team'
      user_1_box = find("#user-#{user_1.id}")
      user_2_box = find("#user-#{user_2.id}")
      user_3_box = find("#user-#{user_3.id}")
      expect(user_1_box).to be_checked
      expect(user_2_box).not_to be_checked
      expect(user_3_box).not_to be_checked

      check("user-#{user_2.id}")
      visit edit_project_path(project)
      click_link 'Team'
      expect(user_1_box).to be_checked
      expect(user_2_box).to be_checked
      expect(user_3_box).not_to be_checked

      click_link 'Remove', href: membership_path(membership_3)
      uncheck("user-#{user_2.id}")

      visit edit_project_path(project)
      click_link 'Team'
      expect(user_1_box).to be_checked
      expect(user_2_box).not_to be_checked
    end

    scenario 'project should have at least one admin' do
      project = create(:project)
      user = project.memberships.first.user

      login_as user
      visit edit_project_path(project)
      click_link 'Team'

      user_box = find("#user-#{user.id}")

      uncheck("user-#{user.id}")
      expect(page).to have_content('Project should have at least one admin!')
      expect(user_box).to be_checked
    end
  end

  before(:each) do
    @user = create(:user_confirmed)
    @admin = create(:user_confirmed)
    @project = create(:project, users: [@admin])
    @user_membership = create(:membership, project: @project, user: @user, admin: false)

    visit team_project_path(@project)
    expect(current_path).to eq(new_user_session_path)
  end

  context 'show team' do
    scenario 'as a comum user' do
      login_as @user

      visit team_project_path(@project)
      expect(page).not_to have_select('post[user]')

      user_box = find("#user-#{@user.id}")
      admin_box = find("#user-#{@admin.id}")

      expect(user_box).not_to be_checked
      expect(admin_box).to be_checked

      expect(user_box).to be_disabled
      expect(admin_box).to be_disabled
      expect(page).not_to have_link('Remove')
    end

    scenario 'as an admin' do
      login_as @admin

      visit edit_project_path(@project)
      user_box = find("#user-#{@user.id}")
      admin_box = find("#user-#{@admin.id}")

      expect(page).to have_select('post[user]', with_options: [
        @user.email,
        @admin.email])
      expect(user_box).not_to be_checked
      expect(admin_box).to be_checked
      expect(page).to have_link('Remove')

      expect(user_box).not_to be_disabled
      expect(admin_box).not_to be_disabled
    end
  end

  scenario 'remove user', js: true do
    login_as @admin
    visit edit_project_path(@project)
    click_link 'Team'

    expect(page).to have_content(@user.email)

    admin_membership = Membership.where(user_id: @admin.id, project_id: @project.id).first
    click_link 'Remove', href: membership_path(admin_membership)
    expect(page).to have_content(@admin.email)
    expect(page).to have_content('Project should have at least one admin!')

    click_link 'Remove', href: membership_path(@user_membership)
    expect(page).to_not have_content(@user.email)
    expect(page).to have_content('User was removed from this project')
    expect(page).to_not have_content('Project should have at least one admin!')

    user_membership = create(:membership, project: @project, user: @user, admin: true)
    visit edit_project_path(@project)
    click_link 'Team'
    click_link 'Remove', href: membership_path(admin_membership)

    expect(page).to_not have_content(@admin.email)
    expect(page).to have_content('User was removed from this project')
  end
end