# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# db/seeds.rb

# Create a test user (only if it doesn't exist)
User.find_or_create_by!(email: "test@example.com") do |user|
  user.first_name = "John"
  user.last_name = "Doe"
  user.password = "password123"
  user.password_confirmation = "password123"
  # Add other fields if needed (e.g., name, admin: false)
end

puts "✅ Seeded test user: test@example.com / John / Doe / password123"
