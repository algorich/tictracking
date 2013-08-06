require 'spec_helper'

feature 'manage project' do
  before do
    @user = create(:user_confirmed)
    login_as @user
  end

  context 'new' do
    scenario 'successfully' do
      user_2 = create(:user)
      visit new_project_path

      fill_in 'Name', with: 'Project_1'
      click_button 'Create Project'
      expect(@user).to be_admin(Project.last)
      expect(page).to have_content('Project was successfully created.')
      expect(page).to have_content('Project_1')
      click_link "Settings"

      within('.team') do
        expect(page).to have_select("select_user_#{@user.id}", selected: ('Admin'))
        expect(page).to have_content(@user.email)
        expect(page).not_to have_content(user_2.email)
      end
    end

    scenario 'failure' do
      visit new_project_path

      click_button 'Create Project'

      expect(page).not_to have_content('Project was successfully created.')
      expect(page).to have_content("Namecan't be blank")
    end
  end

  context "edit" do
    scenario 'successfully', js:true do
      project = create(:project, name: 'Project_1')
      membership = create(:membership, role: 'admin', project: project)
      login_as membership.user
      visit project_path(project)
      expect(page).to have_content('Project_1')
      click_link 'Settings'
      fill_in 'project_name', with: 'Project_Foo'
      click_button 'Update Project'
      expect(page).to have_content('Project was successfully update.')
      expect(page).to have_content('Project_Foo')
    end
  end

  context 'failure' do
    scenario 'name  cant be blank' do
      project = create(:project, name: 'Project_1')
      membership = project.memberships.first
      expect(membership).to be_admin
      user = membership.user
      login_as user

      visit edit_project_path(project)

      fill_in 'project_name', with: ''
      click_button 'Update Project'
      expect(page).not_to have_content('Project_Foo')
      expect(page).to have_content("can't be blank")
    end
  end

  scenario 'should be deletable' do
    project = create(:project, name: 'Project_1')
    membership = create(:membership, role: 'admin', project: project)
    login_as membership.user
    visit edit_project_path(project)
    link_destroy = page.find(:xpath, ".//a[@href=\"/projects/#{project.id}\" and @data-method=\"delete\"]")
    expect(page).to have_content('Project_1')
    link_destroy.click
    visit projects_path
    expect(page).not_to have_content('Project_1')
  end

  context 'listing' do
    before do
      @project = create(:project, name: 'Project_1')
    end

    scenario 'only project admin can show links settings' do
      membership = create(:membership, role: 'admin', project: @project)
      login_as membership.user
      visit project_path(@project)

      link = page.find(:xpath, ".//a[@href=\"/projects/#{@project.id}/edit\"]")
      expect(link).to be_visible

      click_link 'Sign out'

      login_as @user
      visit projects_path
      expect(page).not_to have_content 'Settings'
    end

    scenario 'only members can show projects' do
      visit project_path(@project)
      expect(page).to have_content 'You are not authorized to access this page.'

      membership = create(:membership, project: @project)
      login_as membership.user
      visit project_path(@project)
      expect(page).not_to have_content 'You are not authorized to access this page.'
      expect(current_path).to eq(project_path(@project))
    end
  end

  context 'show' do
    scenario 'users should show only your projects' do
      project = create(:project, name: 'Project GG')
      project_1 = create(:project, users: [@user])
      project_2 = create(:project, users: [@user])
      project_3 = create(:project, users: [@user])
      project_4 = create(:project, users: [@user])

      visit projects_path

      expect(page).not_to have_content project.name
      expect(page).to have_content project_1.name
      expect(page).to have_content project_2.name
      expect(page).to have_content project_3.name
      expect(page).to have_content project_4.name
    end
  end
end