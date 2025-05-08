# db/seeds.rb
require 'faker'

# Clear existing data (child records first)
RecipeItem.destroy_all
Recipe.destroy_all
User.destroy_all
Meal.destroy_all
puts "🧹 Cleaned up existing data..."

# Create test users
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
  user = User.create!(
    email: user_data[:email],
    first_name: user_data[:first_name],
    last_name: user_data[:last_name],
    password: user_data[:password],
    password_confirmation: user_data[:password]
  )

  puts "👤 Created user: #{user.email}"

  # Create 3 recipes for each user (guaranteed to have ingredients)
  40.times do |i|
    begin
      recipe = Recipe.new(
        user: user,
        name: Faker::Food.dish,
        procedure: Faker::Lorem.paragraphs(number: rand(2..4)).join("\n\n"),
        servings: rand(1..6),
        difficulty: rand(1..5),
        prep_time: "#{rand(5..120)} #{rand(0..1) == 0 ? 'minutes' : 'hours'}",
        recipe_type: 1,
        diet: [ 'Vegan', 'Vegetarian', 'Gluten-Free', 'Keto', 'None' ].sample,
        sharable: [ true, false ].sample
      )

      # Create ingredients FIRST (minimum 2, maximum 6)
      ingredients_count = rand(2..6)
      ingredients = ingredients_count.times.map do
        {
          name: Faker::Food.ingredient,
          amount: "#{rand(1..4)} #{[ 'cup', 'tablespoon', 'teaspoon', 'oz', 'grams', 'lbs' ].sample}"
        }
      end

      # Build recipe items before saving recipe
      recipe.recipe_items.build(ingredients)
      recipe.save!

      puts "   🍳 Created recipe '#{recipe.name}' with #{ingredients_count} ingredients"
    rescue => e
      puts "   ❌ Failed to create recipe: #{e.message}"
    end
  end

  20.times do |i|
    # Retry logic in case of failures
    begin

      # Get 1-3 random recipes from this user (at least 1)
      recipes = user.recipes.sample(rand(1..3))

      # Build the meal with mandatory recipe association
      meal = Meal.create!(
        user: user,
        name: "#{Faker::Food.dish}",
        description: Faker::Food.description,
        meal_type: Meal.meal_types.keys.sample,
        sharable: [ true, false ].sample
      )

      # Create the recipe associations
      recipes.each do |recipe|
        meal.meal_recipes.create!(recipe: recipe)
      end

      puts "✅ Created meal '#{meal.name}' with #{meal.recipes.count} recipes"

    rescue => e
      puts "❌ Failed to create meal: #{e.message}"
    end
  end
end

puts "🌱 Seeding complete!"
puts "   Total users: #{User.count}"
puts "   Total recipes: #{Recipe.count}"
puts "   Total recipe items: #{RecipeItem.count}"
puts "   Total meals: #{Meal.count}"
