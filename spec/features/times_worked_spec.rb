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

      @day_before_yesterday = now
    end
  end

  scenario 'report show' do
    login_as @goku

    visit report_project_path(@world_salvation)
    within('#project') do
      expect(page).to have_content @world_salvation.name
      expect(page).to have_content '15 minutes'
    end

    within("#tasks") do
      expect(page).to have_content @task.name
      expect(page).to have_content '5 minutes'

      expect(page).to have_content @task_2.name
      expect(page).to have_content '10 minutes'
    end
  end

  before(:each) do
    Timecop.freeze(@day_before_yesterday) do
      now = Time.now
      @kuririn = create(:user_confirmed, name: 'kuririn')
      create(:membership, project: @resurrect_kuririn, user: @kuririn)
      @die = create(:task, project: @resurrect_kuririn, name: 'die')
      worktime = create(:worktime, task: @die, begin: now, end: now + 2.minutes,
        user: @kuririn )
    end
  end

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

  context 'search like an admin' do
    scenario 'search between times' do
      yesterday = @day_before_yesterday + 1.day
      Timecop.freeze(yesterday) do
        now = Time.now
        @task = create(:task, project: @resurrect_kuririn, name: 'Foo')
        worktime = create(:worktime, task: @task, begin: now,
         end: now + 10.minutes, user: @goku )
      end

      login_as @goku
      visit report_project_path(@resurrect_kuririn)

      expect(page).to have_content @goku.email
      expect(page).to have_content @kuririn.name

      fill_in 'Begin at', with: @day_before_yesterday
      fill_in 'End at', with: ''
      click_button 'Filter'

      within("#user-#{@goku.id} #tasks") do
          expect(page).to have_content @find_dragon_balls.name
          expect(page).to have_content '200 minutes'

          expect(page).to have_content @invoke_shenlong.name
          expect(page).to have_content '5 minutes'

          expect(page).to have_content @task.name
          expect(page).to have_content '10 minutes'
      end

      within("#user-#{@kuririn.id} #tasks") do
        expect(page).to have_content @die.name
        expect(page).to have_content '2 minutes'
      end

      fill_in 'Begin at', with: yesterday
      fill_in 'End at', with: ''
      click_button 'Filter'

      within("#user-#{@kuririn.id} #tasks") do
        expect(page).to_not have_content @die.name
        expect(page).to_not have_content '2 minutes'
      end

      within("#user-#{@goku.id} #tasks") do
          expect(page).to_not have_content @find_dragon_balls.name
          expect(page).to_not have_content '200 minutes'

          expect(page).to_not have_content @invoke_shenlong.name
          expect(page).to_not have_content '5 minutes'

          expect(page).to have_content @task.name
          expect(page).to have_content '10 minutes'
      end

      fill_in 'Begin at', with: @day_before_yesterday
      fill_in 'End at', with: yesterday - 20.minutes
      click_button 'Filter'

      within("#user-#{@kuririn.id} #tasks") do
        expect(page).to have_content @die.name
        expect(page).to have_content '2 minutes'
      end

      within("#user-#{@goku.id} #tasks") do
          expect(page).to have_content @find_dragon_balls.name
          expect(page).to have_content '200 minutes'

          expect(page).to have_content @invoke_shenlong.name
          expect(page).to have_content '5 minutes'

          expect(page).to_not have_content @task.name
          expect(page).to_not have_content '10 minutes'
      end
    end
  end
end