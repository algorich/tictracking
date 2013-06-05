require 'spec_helper'

feature 'manage project' do
  context 'new' do
    scenario 'successfully' do
      visit new_project_path
      expect(page).to have_content 'New Project'

      fill_in 'Name', with: 'project_1'
      click_button 'Create Project'
      expect(page).to have_content 'Project was successfully created.'
    end

    scenario 'failure' do
      visit new_project_path
      
      fill_in 'Name', with: ''
      click_button 'Create Project'

      expect(page).not_to have_content 'Project was successfully created.'
      expect(page).to have_content "Namecan't be blank"
    end
  end
end