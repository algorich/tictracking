require 'spec_helper'

feature 'Times worked' do
  before do
    @yesterday = Time.local(2008, 12, 12, 6, 6, 6) - 1.day
  end

  scenario 'authenticate_user' do
    Timecop.freeze(@yesterday) { @project = create :project }

    visit report_project_path(@project)
    expect(page).to have_content('You need to sign in or sign up before continuing.')

    Timecop.freeze(@yesterday) do
      @user = create(:user_confirmed)
      create(:membership, user: @user, project: @project)
    end

    login_as @user
    visit report_project_path(@project)
    expect(current_path).to eq(report_project_path(@project))
  end

  before(:each) do
    @day_before_yesterday = (@yesterday - 1.day)

    Timecop.freeze(@day_before_yesterday) do
      now = Time.now
      #user goku
      @goku = create(:user_confirmed)
      @world_salvation = create(:project, name: 'World Salvation', users: [@goku])

      @task = create(:task, project: @world_salvation, name: 'Task 1')
      worktime = create(:worktime, task: @task, beginning: now, finish: now + 2.minutes,
        user: @goku )
      worktime = create(:worktime, task: @task, beginning: now, finish: now + 3.minutes,
        user: @goku )

      @task_2 = create(:task, project: @world_salvation, name: 'Task 2')
      worktime = create(:worktime, task: @task_2, beginning: now, finish: now + 10.minutes,
        user: @goku )

      @resurrect_kuririn = create(:project, name: 'Resurrect kuririn', users: [@goku])
      @find_dragon_balls = create(:task, project: @resurrect_kuririn, name: 'find dragon balls')
      worktime = create(:worktime, task: @find_dragon_balls, beginning: now, finish: now + 2.hours,
        user: @goku )
      @invoke_shenlong  = create(:task, project: @resurrect_kuririn, name: 'invoke shenlong')
      worktime = create(:worktime, task: @invoke_shenlong, beginning: now, finish: now + 1.hour,
        user: @goku )

      #user kuririn
      @kuririn = create(:user_confirmed, name: 'kuririn')
      create(:membership, project: @resurrect_kuririn, user: @kuririn)
      @die = create(:task, project: @resurrect_kuririn, name: 'die')
      worktime = create(:worktime, task: @die, beginning: now, finish: now + 2.minutes,
        user: @kuririn )
    end
  end

  context 'show' do
    scenario 'admin' do
      Timecop.freeze(@day_before_yesterday + 6.hours)

      observer = create(:user_confirmed, name: 'observer')
      create :membership, user: observer, project: @resurrect_kuririn, role: 'observer'

      login_as @goku
      visit report_project_path(@resurrect_kuririn)

      expect(page).to have_content @resurrect_kuririn.name
      expect(page).to have_content 'Time worked by all users: 3 hours and 2 minutes'

      #goku
      within("#user-#{@goku.id}") do
        expect(page).to have_content @goku.name
        expect(page).to have_content '3 hours' #time worked at project

        within("#task-#{@find_dragon_balls.id}") do
          expect(page).to have_content @find_dragon_balls.name
          expect(page).to have_content '2 hours'
        end

        within("#task-#{@invoke_shenlong.id}") do
          expect(page).to have_content @invoke_shenlong.name
          expect(page).to have_content '1 hour'
        end
      end

      #kuririn
      within("#user-#{@kuririn.id}") do
        expect(page).to have_content @kuririn.name
        expect(page).to have_content '2 minutes' #time worked at project

        within("#user-#{@kuririn.id}-tasks") do
          expect(page).to have_content @die.name
          expect(page).to have_content '2 minutes' #time worked at task
        end
      end

      expect(page).to_not have_css("#user-#{observer.id}")

      Timecop.return
    end
  end

  context 'filter by user' do
    scenario 'admin', js: true do
      login_as @goku
      visit report_project_path(@resurrect_kuririn)
      expect(page).to have_select('filter_user_ids')

      within('#time_worked') do
        expect(page).to have_content @goku.email
        expect(page).to have_content @kuririn.name
      end

      select(@kuririn.email, from: 'filter_user_ids')
      click_button 'Filter'

      within('#time_worked') do
        expect(page).to_not have_content @goku.email
        expect(page).to have_content @kuririn.name
      end

      select(@goku.email, from: 'filter_user_ids')
      click_button 'Filter'

      within('#time_worked') do
        expect(page).to have_content @goku.email
        expect(page).to have_content @kuririn.name
      end
    end

    scenario 'common user', js: true do
      login_as @kuririn
      visit report_project_path(@resurrect_kuririn)
      expect(page).to_not have_select('filter_user_ids')
    end
  end

  context 'filter by time' do
    before(:each) do
      Timecop.freeze(@yesterday) do
        now = Time.now
        @task = create(:task, project: @resurrect_kuririn, name: 'Foo')
        worktime = create(:worktime, task: @task, beginning: now,
         finish: now + 10.minutes, user: @goku )
      end

      login_as @goku
      visit report_project_path(@resurrect_kuririn)
    end

    scenario 'initial' do
      find_field('filter_begin_at').value.should eq(I18n.l(Time.now.beginning_of_day, format: :datetimepicker))
      find_field('filter_end_at').value.should eq(I18n.l(Time.now, format: :datetimepicker))

      #goku
      within("#user-#{@goku.id}") do
        expect(page).to have_content @goku.name
      end

      #kuririn
      within("#user-#{@kuririn.id}") do
        expect(page).to have_content @kuririn.name
      end
    end

    scenario 'begin_at' do
      fill_in 'filter_begin_at', with: @yesterday + 1.day
      click_button 'Filter'

      within("#user-#{@goku.id}") do
        expect(page).to have_content @goku.name
        expect(page).to have_content ''

        expect(page).to_not have_css("#task-#{@find_dragon_balls.id}")
        expect(page).to_not have_css("#task-#{@invoke_shenlong.id}")
        expect(page).to_not have_css("#task-#{@task.id}")
      end

      within("#user-#{@kuririn.id}") do
        expect(page).to have_content @kuririn.name
        expect(page).to have_content '' #time worked at project

        expect(page).to_not have_css("#task-#{@die.id}")
      end

      fill_in 'filter_begin_at', with: @yesterday
      click_button 'Filter'

      within("#user-#{@goku.id}") do
        expect(page).to have_content @goku.name
        expect(page).to have_content '10 minutes'
        expect(page).to_not have_css("#task-#{@find_dragon_balls.id}")
        expect(page).to_not have_css("#task-#{@invoke_shenlong.id}")

        within("#task-#{@task.id}") do
          expect(page).to have_content @task.name
          expect(page).to have_content '10 minutes'
        end
      end

      within("#user-#{@kuririn.id}") do
        expect(page).to have_content @kuririn.name
        expect(page).to have_content '' #time worked at project

        expect(page).to_not have_css("#task-#{@die.id}")
      end

      fill_in 'filter_begin_at', with: @day_before_yesterday
      click_button 'Filter'

       #goku
      within("#user-#{@goku.id}") do
        expect(page).to have_content @goku.name
        expect(page).to have_content '3 hours and 10 minutes' #time worked at project

        within("#task-#{@find_dragon_balls.id}") do
          expect(page).to have_content @find_dragon_balls.name
          expect(page).to have_content '2 hours'
        end

        within("#task-#{@invoke_shenlong.id}") do
          expect(page).to have_content @invoke_shenlong.name
          expect(page).to have_content '1 hour'
        end

        within("#task-#{@task.id}") do
          expect(page).to have_content @task.name
          expect(page).to have_content '10 minutes'
        end
      end

      #kuririn
      within("#user-#{@kuririn.id}") do
        expect(page).to have_content @kuririn.name
        expect(page).to have_content '2 minutes' #time worked at project

        within("#task-#{@die.id}") do
          expect(page).to have_content @die.name
          expect(page).to have_content '2 minutes'
        end
      end
    end

    scenario 'end_at' do
      fill_in 'filter_begin_at', with: @day_before_yesterday
      fill_in 'filter_end_at', with: @day_before_yesterday
      click_button 'Filter'

      within("#user-#{@goku.id}") do
        expect(page).to have_content @goku.name

        expect(page).to_not have_css("#task-#{@task.id}")
        expect(page).to_not have_css("#task-#{@invoke_shenlong.id}")
        expect(page).to_not have_css("#task-#{@find_dragon_balls.id}")
      end

      within("#user-#{@kuririn.id}") do
        expect(page).to have_content @kuririn.name

        expect(page).to_not have_css("#task-#{@die.id}")
      end

      fill_in 'filter_end_at', with: @yesterday
      click_button 'Filter'

      within("#user-#{@goku.id}") do
        expect(page).to have_content @goku.name
        expect(page).to have_content '3 hours'
        expect(page).to have_css("#task-#{@find_dragon_balls.id}")
        expect(page).to have_css("#task-#{@invoke_shenlong.id}")

        expect(page).to_not have_css("#task-#{@task.id}")
      end

      within("#user-#{@kuririn.id}") do
        expect(page).to have_content @kuririn.name
        expect(page).to have_content '2 minutes' #time worked at project

        expect(page).to have_css("#task-#{@die.id}")
      end

      fill_in 'filter_end_at', with: Time.now
      click_button 'Filter'

       #goku
      within("#user-#{@goku.id}") do
        expect(page).to have_content @goku.name
        expect(page).to have_content '3 hours and 10 minutes' #time worked at project

        within("#task-#{@find_dragon_balls.id}") do
          expect(page).to have_content @find_dragon_balls.name
          expect(page).to have_content '2 hours'
        end

        within("#task-#{@invoke_shenlong.id}") do
          expect(page).to have_content @invoke_shenlong.name
          expect(page).to have_content '1 hour'
        end

        within("#task-#{@task.id}") do
          expect(page).to have_content @task.name
          expect(page).to have_content '10 minutes'
        end
      end

      #kuririn
      within("#user-#{@kuririn.id}") do
        expect(page).to have_content @kuririn.name
        expect(page).to have_content '2 minutes' #time worked at project

        within("#task-#{@die.id}") do
          expect(page).to have_content @die.name
          expect(page).to have_content '2 minutes'
        end
      end
    end
  end
end