# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
p 'users created'

User.delete_all
USER_NUMBER=10
USER_NUMBER.times do |i|
  FactoryGirl.create :user_confirmed, email: "user#{i}@email.com", password: '123456'
end

p 'projects created'

Project.delete_all
users = User.all
5.times do |i|
  FactoryGirl.create :project, name: "Project #{i}", users: [*users.first(rand(USER_NUMBER))]
end

p 'tasks created'

Task.delete_all
Worktime.delete_all

Project.all.each do |p|
  50.times do |i|
    p.tasks.create(name: "Task #{i}")
  end
end

p 'worktime created'

Task.all.each do |t|
  5.times do |i|
    t.worktimes.create beginning: Time.now + "#{i}".to_i.hour,
      finish: Time.now + "#{i+1}".to_i.hour, user: t.project.users.sample
  end
end