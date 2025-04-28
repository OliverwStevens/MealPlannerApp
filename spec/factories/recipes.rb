# spec/factories/recipes.rb
FactoryBot.define do
  factory :recipe do
    sequence(:name) { |n| "Recipe #{n}" }
    procedure { Faker::Lorem.paragraph(sentence_count: 3) }
    servings { rand(1..10) }
    difficulty { rand(1..5) }
    prep_time { "#{rand(1..60)} mins" }
    recipe_type { rand(0..3) }
    diet { %w[vegetarian vegan gluten-free keto none].sample }
    sharable { [ true, false ].sample }
    association :user

    trait :vegetarian do
      diet { 'vegetarian' }
    end

    trait :vegan do
      diet { 'vegan' }
    end

    trait :private do
      sharable { false }
    end

    trait :quick do
      prep_time { "15 mins" }
      difficulty { 1 }
    end

    trait :complex do
      prep_time { "120 mins" }
      difficulty { 5 }
      procedure { Faker::Lorem.paragraph(sentence_count: 10) }
    end

    trait :breakfast do
      recipe_type { 0 }
    end

    trait :lunch do
      recipe_type { 1 }
    end

    trait :dinner do
      recipe_type { 2 }
    end

    trait :dessert do
      recipe_type { 3 }
    end
  end
end
