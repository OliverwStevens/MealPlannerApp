FactoryBot.define do
  factory :meal do
    name { Faker::Food.dish }
    description { "MyText" }
    sharable { [ true, false ].sample }
    association :user
    meal_type { [ "breakfast", "lunch", "dinner" ].sample }

    # Define how many items to create (default: 1-5)
    trait :with_recipes do
      transient do
        recipes_count { 2 }
      end

      after(:create) do |meal, evaluator|
        create_list(:recipe, evaluator.recipes_count, meal: meal)
      end
    end
  end
end
