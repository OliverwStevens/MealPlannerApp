# db/seeds.rb


# Create test users with pantry items
users = [
  {
    email: "test@example.com",
    first_name: "John",
    last_name: "Doe",
    password: "password123"
  },
  {
    email: "jane@example.com",
    first_name: "Jane",
    last_name: "Smith",
    password: "password123"
  }
]

users.each do |user_data|
  user = User.find_or_create_by!(email: user_data[:email]) do |u|
    u.first_name = user_data[:first_name]
    u.last_name = user_data[:last_name]
    u.password = user_data[:password]
    u.password_confirmation = user_data[:password]
  end

  puts "✅ Created user: #{user.email}"
end

puts "🌱 Seeding complete! Created #{User.count} users."
