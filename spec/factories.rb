FactoryGirl.define do
  factory :project do
    name "project_name"
    users { [create(:user)] }
  end

  factory :task do
    name 'tarefa x'
    project { create(:project) }
  end

  factory :worktime do
    self.begin Time.now
    self.end Time.now + 1.day
    user { [create(:user)] }
    task { create(:task) }
  end

  factory :user do
    sequence(:email) {|n| "user#{n}@email.com" }
    password '123456'

    factory :user_confirmed do
      after(:create) { |u| u.confirm! }
    end
  end
end