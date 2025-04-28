FactoryBot.define do
  factory :meal_recipe do
    meal { nil }
    recipe { nil }
    position { 1 }
    notes { "MyText" }
  end
end
