require 'spec_helper'

feature 'Dashboard' do
  background do
    @user = create(:user_confirmed)
  end

  scenario 'Page after login' do
    visit dashboard_path
    expect(current_path).to eq(new_user_session_path)
    expect(page).to have_content 'You need to sign in or sign up before continuing.'

    fill_in 'Email', with: @user.email
    fill_in 'Password', with: @user.password
    click_button 'Sign in'
    expect(current_path).to eq(dashboard_path)
  end

  context 'Content' do
    before(:each) { login_as @user }

    scenario 'should have links to create and list projects' do
      visit dashboard_path
      expect(page).to have_link('My projects', href: projects_path)
      expect(page).to have_link('New project', href: new_project_path)
    end

    scenario 'should the 3 latest tasks and projects' do
      5.times { |i| create(:project, name: "Project #{i}", users: [@user] ) }
      visit dashboard_path

      expect(page).to have_content('Project 4')
      expect(page).to have_content('Project 3')
      expect(page).to have_content('Project 2')
      expect(page).not_to have_content('Project 1')
      expect(page).not_to have_content('Project 0')
    end
  end
end