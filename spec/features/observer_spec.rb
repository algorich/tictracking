require 'spec_helper'

feature 'Observer' do
  before(:each) do
    Timecop.freeze(Time.local(2008, 12, 12, 6, 6, 6) - 2.day) do
      now = Time.now

      #user goku
      @goku = create(:user_confirmed)
      @resurrect_kuririn = create(:project, name: 'Resurrect kuririn', users: [@goku])
      @find_dragon_balls = create(:task, project: @resurrect_kuririn, name: 'find dragon balls')
      worktime = create(:worktime, task: @find_dragon_balls, beginning: now, finish: now + 2.minutes,
        user: @goku )
      @invoke_shenlong  = create(:task, project: @resurrect_kuririn, name: 'invoke shenlong')
      worktime = create(:worktime, task: @invoke_shenlong, beginning: now, finish: now + 5.minutes,
        user: @goku )

      #user kuririn
      @kuririn = create(:user_confirmed, name: 'kuririn')
      create(:membership, project: @resurrect_kuririn, user: @kuririn)
      @die = create(:task, project: @resurrect_kuririn, name: 'die')
      worktime = create(:worktime, task: @die, beginning: now, finish: now + 2.minutes,
        user: @kuririn )

      @day_before_yesterday = now
    end


    #observer
    @client = create(:user_confirmed)
    create(:membership, project: @resurrect_kuririn, user: @client, role: 'observer')
    login_as @client
  end

  scenario 'Project#show' do
    visit project_path(@resurrect_kuririn)
    expect(page).to have_content @resurrect_kuririn.name

    expect(page).to_not have_field 'New task'
    expect(page).to_not have_css("#actions a[data-method=\"post\"]") #start
    expect(page).to_not have_css("#actions a[data-method=\"put\"]") #stop
  end

  context 'Project#report' do
    scenario 'show' do
      Timecop.travel(@day_before_yesterday + 10.hours)

      visit report_project_path(@resurrect_kuririn)
      expect(page).to have_select 'filter_user_ids'

      within('#project') do
        expect(page).to have_content @goku.email
        expect(page).to have_content @kuririn.name
        expect(page).to_not have_content @client.email
      end

      #goku
      within("#user-#{@goku.id}") do
        expect(page).to have_content @goku.name
        expect(page).to have_content '7 minutes' #time worked at project

        within("#task-#{@find_dragon_balls.id}") do
          expect(page).to have_content @find_dragon_balls.name
          expect(page).to have_content '2 minutes'
        end

        within("#task-#{@invoke_shenlong.id}") do
          expect(page).to have_content @invoke_shenlong.name
          expect(page).to have_content '5 minutes'
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

      Timecop.return
    end

    scenario 'filter by user' do
      visit report_project_path(@resurrect_kuririn)

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
    end

    context 'filter by time' do
      before(:each) do
        @yesterday = @day_before_yesterday + 1.day
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
          expect(page).to have_content '17 minutes' #time worked at project

          within("#task-#{@find_dragon_balls.id}") do
            expect(page).to have_content @find_dragon_balls.name
            expect(page).to have_content '2 minutes'
          end

          within("#task-#{@invoke_shenlong.id}") do
            expect(page).to have_content @invoke_shenlong.name
            expect(page).to have_content '5 minutes'
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
        fill_in 'filter_begin_at', with: @resurrect_kuririn.created_at
        fill_in 'filter_end_at', with: @day_before_yesterday
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

        fill_in 'filter_end_at', with: @yesterday
        click_button 'Filter'

        within("#user-#{@goku.id}") do
          expect(page).to have_content @goku.name
          expect(page).to have_content '7 minutes'
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
          expect(page).to have_content '17 minutes' #time worked at project

          within("#task-#{@find_dragon_balls.id}") do
            expect(page).to have_content @find_dragon_balls.name
            expect(page).to have_content '2 minutes'
          end

          within("#task-#{@invoke_shenlong.id}") do
            expect(page).to have_content @invoke_shenlong.name
            expect(page).to have_content '5 minutes'
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
end