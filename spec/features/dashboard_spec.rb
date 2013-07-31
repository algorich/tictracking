require 'spec_helper'

feature 'Dashboard' do
  background do
    @user = create(:user_confirmed)
  end

  scenario 'should a message if user dont have projects' do
    login_as @user
    visit root_path
    expect(page).to have_content('You still do not have any project')
  end

  scenario 'should a message if user dont have tasks' do
    login_as @user
    project = create :project
    membership = create :membership, project: project, user: @user, admin: true
    visit root_path
    expect(page).to have_content('Create a task')
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
      expect(page).to have_link('All Projects', href: projects_path)
      expect(page).to have_link('New Project', href: new_project_path)
    end

    scenario 'should have the 3 latest projects' do
      5.times { |i| create(:project, name: "Project #{i}", users: [@user] ) }
      visit dashboard_path

      expect(page).to have_content('Project 4')
      expect(page).to have_content('Project 3')
      expect(page).to have_content('Project 2')
      expect(page).not_to have_content('Project 1')
      expect(page).not_to have_content('Project 0')
    end

    scenario 'should have the 3 latest tasks with the projects name' do
      project_1 = create(:project, users: [@user], name: 'World Domination')
      project_2 = create(:project, users: [@user], name: 'Buy Coffee')
      task_1 = create(:task, project: project_1, name: 'Task 1')
      task_2 = create(:task, project: project_1, name: 'Task 2')
      task_3 = create(:task, project: project_2, name: 'Task 3')
      task_4 = create(:task, project: project_2, name: 'Task 4')

      create(:worktime, user: @user, task: task_1)

      create(:worktime, user: @user, task: task_4)

      create(:worktime, user: @user, task: task_3)

      create(:worktime, user: @user, task: task_2)
      create(:worktime, user: @user, task: task_2)

      visit dashboard_path

      expect(page).to have_content('Task 4 (Buy Coffee)')
      expect(page).to have_content('Task 3 (Buy Coffee)')
      expect(page).to have_content('Task 2 (World Domination)')
      expect(page).not_to have_content('Task 1 (World Domination)')
    end
  end
end