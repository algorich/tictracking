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
    before(:each) do
      login_as @user
      visit dashboard_path
    end
    scenario 'should have links to create and list projects' do
      expect(page).to have_link('My projects', href: projects_path)
      expect(page).to have_link('New project', href: new_project_path)
    end

    scenario 'should the 3 latest tasks and projects' do
      8.times do |i|
        project = create(:project, name: "Project #{i}", users: [@user] )
      end

      expect(page).to have_content('Project 7')
      expect(page).to have_content('Project 6')
      expect(page).to have_content('Project 5')
    end
  end
end
