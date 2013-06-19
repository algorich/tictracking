FactoryGirl.define do
  factory :project do
    name "project_name"
    after(:build) do |p|
      p.memberships = [build(:membership, project: p)] if p.memberships.empty?
    end
  end

  factory :task do
    sequence(:name) { |n| "tarefa #{n}" }
    project { create(:project) }
  end

  factory :worktime do
    self.begin Time.now
    self.end Time.now + 1.day
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
    project { create(:project) }
    user { create(:user_confirmed) }
  end
end