FactoryBot.define do
  factory :meal_plan do
    association :user
    association :meal
    date { Date.today }
  end
end
