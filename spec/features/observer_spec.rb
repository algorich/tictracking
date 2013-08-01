require 'spec_helper'

feature 'Dashboard' do
  before(:each) do
    now = Time.now

    @goku = create(:user_confirmed)

    @resurrect_kuririn = create(:project, name: 'Resurrect kuririn', users: [@goku])
    @find_dragon_balls = create(:task, project: @resurrect_kuririn, name: 'find dragon balls')
    worktime = create(:worktime, task: @find_dragon_balls, beginning: now, finish: now + 3.days,
      user: @goku )
    @invoke_shenlong  = create(:task, project: @resurrect_kuririn, name: 'invoke shenlong')
    worktime = create(:worktime, task: @invoke_shenlong, beginning: now, finish: now + 5.minutes,
      user: @goku )

    #user kuririn
    @kuririn = create(:user_confirmed, name: 'kuririn')
    create(:membership, project: @resurrect_kuririn, user: @kuririn)
    @die = create(:task, project: @resurrect_kuririn, name: 'die')
    worktime = create(:worktime, task: @die, beginning: now, finish: now + 1.hour + 2.minutes,
      user: @kuririn )
  end

  scenario 'Project#show', js: true do
    client = create(:user_confirmed)
    create(:membership, project: @resurrect_kuririn, user: client, observer: true)
    login_as client

    visit project_path(@resurrect_kuririn)
    expect(page).to have_content @resurrect_kuririn.name

    expect(page).to_not have_field 'New task'
    expect(page).to_not have_css("#actions a[data-method=\"post\"]") #start
    expect(page).to_not have_css("#actions a[data-method=\"put\"]") #stop

    visit report_project_path(@resurrect_kuririn)
    expect(page).to have_select 'filter_user_id'
    expect(page).to have_content @goku.email
    expect(page).to have_content @kuririn.name

    within('#project') do
      expect(page).to_not have_content client.email
    end
  end
end