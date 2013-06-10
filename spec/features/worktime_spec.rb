require 'spec_helper'

feature 'Worktime' do
  background do
    @user = User.create(email: 'greenlantern@gmail.com',
     password: '123456')
    @user.confirm!
    login_as @user
    @project = Project.create(name: 'Project X')
  end

  context 'create' do
    scenario 'successfully create worktime' do
      @task = Task.create(name: 'tarefa x', project_id: @project.id)
      @worktime = Worktime.create(begin: Time.now, end: Time.now + 1.day,
       user_id: @user.id, task_id: @task.id)
      visit project_path(@project)
      time = Time.local(2008, 9, 1, 10, 5, 0)
      Timecop.freeze(time)
      click_button 'Begin'
      expect(page).to have_content '2008-09-01 13:05:00 UTC'
    end
  end
end