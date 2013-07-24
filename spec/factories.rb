FactoryGirl.define do
  factory :project do
    sequence(:name) { |n| "project_#{n}"}

    before(:create) do |project, evaluator|
      user = evaluator.users.first || create(:user_confirmed)
      evaluator.users.delete(user)
      evaluator.users = evaluator.users
      project.set_admin(user)
    end
  end

  factory :task do
    sequence(:name) { |n| "tarefa #{n}" }
    project { create(:project) }
  end

  factory :worktime do
    self.begin Time.now
    self.end Time.now + 1.minute
    user { create(:user) }
    task { create(:task) }
  end

  factory :user do
    sequence(:email) {|n| "user#{n}@email.com" }
    password '123456'

    factory :user_confirmed do
      after(:create) { |u| u.confirm! }
    end
  end

  factory :membership do
    admin false

    before(:create) do |membership, evaluator|
      user = evaluator.user || create(:user_confirmed)
      membership.user = user
      membership.project = evaluator.project || create(:project, users: [user])
    end
  end
end