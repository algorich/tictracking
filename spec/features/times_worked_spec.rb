require 'spec_helper'

feature 'Times worked' do
  scenario 'authenticate_user' do
    Timecop.freeze(Time.now - 1.day) { @project = create :project }
    visit report_project_path(@project)
    expect(page).to have_content('You need to sign in or sign up before continuing.')

    Timecop.freeze(Time.now - 1.day) do
      @user = create(:user_confirmed)
      create(:membership, user: @user, project: @project)
    end

    login_as @user
    visit report_project_path(@project)
    expect(current_path).to eq(report_project_path(@project))
  end

  before(:each) do
    Timecop.freeze(Time.now - 2.day) do
      #user goku
      @goku = create(:user_confirmed)
      @world_salvation = create(:project, name: 'World Salvation', users: [@goku])

      @task = create(:task, project: @world_salvation, name: 'Task 1')
      now = Time.now
      worktime = create(:worktime, task: @task, begin: now, end: now + 2.minutes,
        user: @goku )
      worktime = create(:worktime, task: @task, begin: now, end: now + 3.minutes,
        user: @goku )

      @task_2 = create(:task, project: @world_salvation, name: 'Task 2')
      worktime = create(:worktime, task: @task_2, begin: now, end: now + 10.minutes,
        user: @goku )

      @resurrect_kuririn = create(:project, name: 'Resurrect kuririn', users: [@goku])
      @find_dragon_balls = create(:task, project: @resurrect_kuririn, name: 'find dragon balls')
      worktime = create(:worktime, task: @find_dragon_balls, begin: now, end: now + 200.minutes,
        user: @goku )
      @invoke_shenlong  = create(:task, project: @resurrect_kuririn, name: 'invoke shenlong')
      worktime = create(:worktime, task: @invoke_shenlong, begin: now, end: now + 5.minutes,
        user: @goku )

      #user kuririn
      @kuririn = create(:user_confirmed, name: 'kuririn')
      create(:membership, project: @resurrect_kuririn, user: @kuririn)
      @die = create(:task, project: @resurrect_kuririn, name: 'die')
      worktime = create(:worktime, task: @die, begin: now, end: now + 2.minutes,
        user: @kuririn )

      @day_before_yesterday = now
    end
  end

  context 'show' do
    scenario 'admin' do
      login_as @goku
      visit report_project_path(@resurrect_kuririn)

      within('#project') do
        expect(page).to have_content @resurrect_kuririn.name
      end

      within("#user-#{@kuririn.id}") do
        expect(page).to have_content @kuririn.name
        expect(page).to have_content '2 minutes' #time worked at project

        within('#tasks') do
          expect(page).to have_content @die.name
          expect(page).to have_content '2 minutes' #time worked at task
        end
      end

      within("#user-#{@goku.id}") do
        expect(page).to have_content @goku.name
        expect(page).to have_content '205 minutes' #time worked at project

        within("#tasks #task-#{@find_dragon_balls.id}") do
          expect(page).to have_content @find_dragon_balls.name
          expect(page).to have_content '200 minutes'
        end

        within("#tasks #task-#{@invoke_shenlong.id}") do
          expect(page).to have_content @invoke_shenlong.name
          expect(page).to have_content '5 minutes'
        end
      end
    end

    scenario 'common user' do
      login_as @kuririn
      visit report_project_path(@resurrect_kuririn)

      within("#user-#{@kuririn.id}") do
        expect(page).to have_content @kuririn.name
        expect(page).to have_content '2 minutes' #time worked at project

        within('#tasks') do
          expect(page).to have_content @die.name
          expect(page).to have_content '2 minutes' #time worked at task
        end
      end

      expect(page).to_not have_css("#user-#{@goku.id}")
    end
  end

  context 'search like an admin' do
    scenario 'admin', js: true do
      login_as @goku
      visit report_project_path(@resurrect_kuririn)
      expect(page).to have_select('filter_user_id')

      within('#time_worked') do
        expect(page).to have_content @goku.email
        expect(page).to have_content @kuririn.name
      end

      select(@kuririn.email, from: 'filter_user_id')
      click_button 'Filter'

      within('#time_worked') do
        expect(page).to_not have_content @goku.email
        expect(page).to have_content @kuririn.name
      end

      select(@goku.email, from: 'filter_user_id')
      click_button 'Filter'

      within('#time_worked') do
        expect(page).to have_content @goku.email
        expect(page).to_not have_content @kuririn.name
      end
    end

    scenario 'common user', js: true do
      login_as @kuririn
      visit report_project_path(@resurrect_kuririn)
      expect(page).to_not have_select('filter_user_id')
    end
  end
end