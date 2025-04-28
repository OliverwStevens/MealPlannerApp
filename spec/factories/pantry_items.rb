FactoryBot.define do
  factory :pantry_item do
    name { Faker::Food.unique.ingredient }
    barcode { Faker::Barcode.unique.ean(13) }
    association :user
    img_url { Faker::Internet.url(path: "/#{name.parameterize}.jpg") }
  end
end
