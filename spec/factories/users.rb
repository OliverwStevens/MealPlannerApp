FactoryBot.define do
  factory :user do
    email { "test@example.com" }
    first_name { "John" }
    last_name { "Doe" }
    password { 'password123' }
    password_confirmation { 'password123' }
  end
end
