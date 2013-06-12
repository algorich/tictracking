require 'spec_helper'

feature 'manage project' do
  before do
    @user = create(:user_confirmed)
    login_as @user
  end

  context 'new' do
    scenario 'successfully' do
      user_1 = create(:user_confirmed)
      user_2 = create(:user_confirmed)
      user_3 = create(:user_confirmed)
      visit new_project_path
      expect(page).to have_content 'New Project'

      fill_in 'Name', with: 'Project_1'
      select user_1.email
      select user_2.email

      click_button 'Create Project'
      expect(page).to have_content 'Project was successfully created.'
      expect(page).to have_content 'Project_1'
      expect(page).to have_content user_1.email
      expect(page).to have_content user_2.email
      expect(page).not_to have_content user_3.email
    end

    scenario 'failure' do
      visit new_project_path

      fill_in 'Name', with: ''
      click_button 'Create Project'

      expect(page).not_to have_content 'Project was successfully created.'
      expect(page).to have_content "Namecan't be blank"
    end
  end

  scenario 'should be editable' do
    project = create(:project, name: 'Project_1')
    visit edit_project_path(project)
    expect(page).to have_content 'Edit Project_1'

    fill_in 'Name', with: 'Project_Foo'
    click_button 'Update Project'
    expect(page).to have_content 'Project was successfully updated.'
    expect(page).to have_content 'Project_Foo'
  end

  scenario 'should be deletable' do
    project = create(:project, name: 'Project_1')
    visit projects_path
    expect(page).to have_content 'Project_1'

    click_link 'Destroy'
    expect(page).not_to have_content 'Project_1'
  end
end