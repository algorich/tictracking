require 'spec_helper'

feature 'Project team' do
  before(:each) do
    @user = create(:user_confirmed)
    @admin = create(:user_confirmed)
    @project = create(:project, users: [@admin])
    @user_membership = create(:membership, project: @project, user: @user, role: 'common_user')
    @admin_membership = @admin.membership(@project)

    visit team_project_path(@project)
    expect(current_path).to eq(new_user_session_path)
  end

  context 'team at project#edit' do
    scenario 'show' do
      login_as @admin

      visit edit_project_path(@project)

      expect(page).to have_select('post[user]', with_options: [
        @user.email,
        @admin.email])

      expect(page).to have_link 'Remove', href: membership_path(@user_membership)
      expect(page).to have_link 'Remove', href: membership_path(@admin_membership)

      expect(page).to have_select("select_user_#{@admin.id}", selected: ('Admin'), disabled: false)
      expect(page).to have_select("select_user_#{@user.id}", selected: ('Common user'),  disabled: false)
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

      user_membership = create(:membership, project: @project, user: @user, role: 'admin')
      visit edit_project_path(@project)
      click_link 'Team'
      click_link 'Remove', href: membership_path(admin_membership)

      expect(page).to_not have_content(@admin.email)
      expect(page).to have_content('User was removed from this project')
    end

    context 'Change users roles', js:true do
      scenario 'should have a select to set the admins, user and observers on project#team' do
        user_1 = create(:user_confirmed)
        user_2 = create(:user_confirmed)
        user_3 = create(:user_confirmed)
        project = create(:project, users: [user_1]) #project's admin
        create(:membership, project: project, user: user_2, role: 'common_user')
        membership_3 = create(:membership, project: project, user: user_3, role: 'observer')

        login_as user_1
        visit edit_project_path(project)
        click_link 'Team'
        expect(page).to have_select("select_user_#{user_1.id}", selected: ('Admin'))
        expect(page).to have_select("select_user_#{user_2.id}", selected: ('Common user'))
        expect(page).to have_select("select_user_#{user_3.id}", selected: ('Observer'))

        select 'Admin', from: "select_user_#{user_2.id}"
        select 'Common user', from: "select_user_#{user_3.id}"
        visit edit_project_path(project)
        click_link 'Team'
        expect(page).to have_select("select_user_#{user_1.id}", selected: ('Admin'))
        expect(page).to have_select("select_user_#{user_2.id}", selected: ('Admin'))
        expect(page).to have_select("select_user_#{user_3.id}", selected: ('Common user'))
      end

      scenario 'project should have at least one admin' do
        project = create(:project)
        user = project.memberships.first.user

        login_as user
        visit edit_project_path(project)
        click_link 'Team'

        expect(page).to have_select("select_user_#{user.id}", selected: ('Admin'))
        select 'Common user', from: "select_user_#{user.id}"

        expect(page).to have_content('Project should have at least one admin!')
        expect(page).to have_select("select_user_#{user.id}", selected: ('Admin'))
      end
    end
  end

  context 'team at project#team' do
    scenario 'show as a comum user' do
      login_as @user

      visit team_project_path(@project)
      expect(page).not_to have_select('post[user]')

      expect(page).to_not have_link 'Remove'

      expect(page).to have_select("select_user_#{@admin.id}", selected: ('Admin'), disabled: true)
      expect(page).to have_select("select_user_#{@user.id}", selected: ('Common user'),  disabled: true)
    end

    scenario 'show as a comum admin' do
      login_as @admin

      visit team_project_path(@project)
      expect(page).not_to have_select('post[user]')

      expect(page).to_not have_link 'Remove'

      expect(page).to have_select("select_user_#{@admin.id}", selected: ('Admin'), disabled: true)
      expect(page).to have_select("select_user_#{@user.id}", selected: ('Common user'),  disabled: true)
    end
  end
end