FactoryGirl.define do
  factory :project do
    name "project_name"
    users { [create(:user)] }
  end

  factory :user do
    sequence(:email) {|n| "user#{n}@email.com" }
    password '123456'

    factory :user_confirmed do
      after(:create) { |u| u.confirm! }
    end
  end
end