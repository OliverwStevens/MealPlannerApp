FactoryBot.define do
  factory :recipe_item do
    # Use transient attributes to allow overriding name and amount
    transient do
      item_name { nil }
      item_amount { nil }
    end

    name { item_name || Faker::Food.ingredient }
    amount { item_amount || "#{rand(1..4)} #{[ 'cup', 'tbsp', 'tsp', 'oz', 'g' ].sample}" }
    association :recipe
  end
end
