require 'spec_helper'

feature 'Times worked' do
  scenario 'authenticate_user' do
    visit times_worked_index_path
    expect(page).to have_content('You need to sign in or sign up before continuing.')

    visit times_worked_admin_path
    expect(page).to have_content('You need to sign in or sign up before continuing.')

    login_as create(:user_confirmed)

    visit times_worked_index_path
    expect(current_path).to eq(times_worked_index_path)

    visit times_worked_admin_path
    expect(current_path).to eq(times_worked_admin_path)
  end

  before(:each) do
    @goku = create(:user_confirmed)
    @world_salvation = create(:project, name: 'World Salvation', users: [@goku])
    @task = create(:task, project: @world_salvation, name: 'Task 1')
    @now = Time.now
    worktime = create(:worktime, task: @task, begin: @now, end: @now + 2.minutes,
      user: @goku )
    worktime = create(:worktime, task: @task, begin: @now, end: @now + 3.minutes,
      user: @goku )

    @task_2 = create(:task, project: @world_salvation, name: 'Task 2')
    worktime = create(:worktime, task: @task_2, begin: @now, end: @now + 10.minutes,
      user: @goku )

    @resurrect_kuririn = create(:project, name: 'World Salvation', users: [@goku])
    @find_dragon_balls = create(:task, project: @resurrect_kuririn, name: 'find dragon balls')
    worktime = create(:worktime, task: @find_dragon_balls, begin: @now, end: @now + 10.days,
      user: @goku )
  end

  scenario 'index' do
    login_as @goku

    visit times_worked_index_path
    within('#projects') do
      expect(page).to have_content @world_salvation.name
      expect(page).to have_content '5 minutes'

      expect(page).to have_content @resurrect_kuririn.name
      expect(page).to have_content  "#{10.days/1.minutes} minutes"
    end

    within("#tasks-of-project-#{@world_salvation.id}") do
      expect(page).to have_content @task.name
      expect(page).to have_content '5 minutes'

      expect(page).to have_content @task_2.name
      expect(page).to have_content '10 minutes'
    end

    within("#tasks-of-project-#{@resurrect_kuririn.id}") do
      expect(page).to have_content @find_dragon_balls.name
      expect(page).to have_content "#{10.days/1.minutes} minutes"
    end
  end

  scenario 'admin' do
    kuririn = create(:user_confirmed, name: 'kuririn')
    create(:membership, project: @resurrect_kuririn, user: kuririn)
    die = create(:task, project: @resurrect_kuririn, name: 'die')
    worktime = create(:worktime, task: die, begin: @now, end: @now + 2.minutes,
      user: kuririn )
    login_as kuririn

    visit times_worked_admin_path
    expect(page).to have_content "Sorry. You do not have projects under your vigilance."

    login_as @goku
    visit times_worked_admin_path
    expect(page).to_not have_content "Sorry. You do not have projects under your vigilance."

    within('#projects') do
      expect(page).to have_content @world_salvation.name
      expect(page).to have_content @resurrect_kuririn.name
    end

    within("#project-#{@resurrect_kuririn.id}") do
      expect(page).to have_content kuririn.name
      expect(page).to have_content @goku.email
    end

    within("#user-#{kuririn.id}") do
      expect(page).to have_content die.name
      expect(page).to have_content "2 minutes"
      expect(page).to_not have_content @find_dragon_balls.name
      expect(page).to_not have_content "#{10.days/1.minutes} minutes"
    end

    within("#project-#{@resurrect_kuririn.id} #user-#{@goku.id}") do
      expect(page).to_not have_content die.name
      expect(page).to_not have_content "2 minutes"
      expect(page).to have_content @find_dragon_balls.name
      expect(page).to have_content "#{10.days/1.minutes} minutes"
    end

    within("#project-#{@world_salvation.id} #user-#{@goku.id}") do
      expect(page).to have_content @task.name
      expect(page).to have_content '5 minutes'

      expect(page).to have_content @task_2.name
      expect(page).to have_content '10 minutes'
    end
  end
end