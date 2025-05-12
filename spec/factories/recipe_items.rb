FactoryBot.define do
  factory :recipe_item do
    name { Faker::Food.ingredient }
    amount { "#{rand(1..4)} #{[ 'cup', 'tbsp', 'tsp', 'oz' ].sample}" }
    association :recipe
  end
end
