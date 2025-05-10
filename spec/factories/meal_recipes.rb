FactoryBot.define do
  factory :meal_recipe do
    association :meal
    association :recipe
  end
end
