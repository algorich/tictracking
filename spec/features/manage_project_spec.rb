require 'spec_helper'

feature 'manage project' do
  before do
    @user = create(:user_confirmed)
    login_as @user
  end

  context 'new' do
    scenario 'successfully' do
      user_1 = create(:user)
      user_2 = create(:user)
      user_3 = create(:user)
      visit new_project_path

      fill_in 'Name', with: 'Project_1'
      select user_1.email
      select user_2.email

      click_button 'Create Project'
      expect(@user).to be_admin(Project.last)
      expect(page).to have_content('Project was successfully created.')
      expect(page).to have_content('Project_1')

      click_link "Team"

      admin_box = find("#user-#{@user.id}")
      expect(admin_box).to be_checked

      expect(page).to have_content(user_1.email)
      expect(page).to have_content(user_2.email)
      expect(page).not_to have_content(user_3.email)
    end

    scenario 'failure' do
      visit new_project_path

      click_button 'Create Project'

      expect(page).not_to have_content('Project was successfully created.')
      expect(page).to have_content("Namecan't be blank")
    end
  end

  context "edit" do
    scenario 'successfully' do
      project = create(:project, name: 'Project_1')
      membership = create(:membership, admin: true, project: project)
      login_as membership.user
      visit edit_project_path(project)
      expect(page).to have_content('Edit Project_1')

      fill_in 'Name', with: 'Project_Foo'
      click_button 'Update Project'
      expect(page).to have_content('Project was successfully updated.')
      expect(page).to have_content('Project_Foo')
    end

    context 'failure' do
      scenario 'name and user cant be blank' do
        project = create(:project, name: 'Project_1')
        membership = project.memberships.first
        membership.toggle_admin!
        user = membership.user
        login_as user

        visit edit_project_path(project)
        expect(page).to have_content('Edit Project_1')

        fill_in 'Name', with: ''
        click_button 'Update Project'
        expect(page).not_to have_content('Project_Foo')
        expect(page).to have_content("Namecan't be blank")

        visit edit_project_path(project)
        fill_in 'Name', with: 'Something'
        unselect user.email

        click_button 'Update Project'
        expect(page).to have_content("can't be blank")
      end
    end
  end

  scenario 'should be deletable' do
    project = create(:project, name: 'Project_1')
    membership = create(:membership, admin: true, project: project)
    login_as membership.user
    visit projects_path
    expect(page).to have_content('Project_1')

    click_link 'Destroy'
    expect(page).not_to have_content('Project_1')
  end

  context 'listing' do
    before do
      @project = create(:project, name: 'Project_1')
    end

    scenario 'only project admin can show links edit and destroy' do
      membership = create(:membership, admin: true, project: @project)
      login_as membership.user
      visit projects_path

      link = page.find(:xpath, ".//a[@href=\"/projects/#{@project.id}/edit\"]")
      link_delete = page.find(:xpath, ".//a[@href=\"/projects/#{@project.id}\"
                                        and @data-method=\"delete\"]")
      expect(link).to be_visible
      expect(link_delete).to be_visible

      click_link 'Sign out'

      login_as @user
      visit projects_path
      expect(page).not_to have_content 'Edit'
      expect(page).not_to have_content 'Destroy'
    end

    scenario 'only members can show projects' do
      membership = create(:membership, project: @project)
      visit project_path(@project)
      expect(page).to have_content 'You are not authorized to access this page.'

      login_as membership.user
      visit project_path(@project)
      expect(page).not_to have_content 'You are not authorized to access this page.'
      expect(current_path).to eq(project_path(@project))
    end
  end

  context 'show' do
    scenario 'users should show only your projects' do
      project = create(:project, name: 'Project GG')
      project = create(:project, users: [@user])
      membership = create(:membership, project: project, user: @user, admin: true)
      visit projects_path
      expect(page).not_to have_content 'Project GG'
    end
  end
end