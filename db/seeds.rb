# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
p 'users created'

User.delete_all
USER_NUMBER=4
USER_NUMBER.times do |i|
  FactoryGirl.create :user_confirmed, email: "user#{i}@mail.com", password: '123456'
end

p 'projects created'

Project.delete_all
users = User.all
5.times do |i|
  FactoryGirl.create :project, name: "Project #{i}", users: [users[rand(USER_NUMBER)]]
end

p 'tasks created'

Task.delete_all
Worktime.delete_all

Project.all.each do |p|
  5.times do |i|
    task = p.tasks.create(name: "Task #{i}")
  end
end

p 'worktime created'

Task.all.each do |t|
  5.times do |i|
    worktime = t.worktimes.create(begin: Time.now + "#{i}".to_i.day,
     end: Time.now + "#{i+1}".to_i.day, user: users[rand(USER_NUMBER)])
  end
end


# Worktime.create!(begin: Time.now, end: Time.now + 1.day, user: user, task: task)

