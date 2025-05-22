require 'faker'

# Clear existing data (child records first)
PantryItem.destroy_all
RecipeItem.destroy_all
Recipe.destroy_all
User.destroy_all
Meal.destroy_all
puts "🧹 Cleaned up existing data..."

# Clear Faker unique cache to prevent barcode collisions
Faker::Barcode.unique.clear

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

  # Create 40 recipes for each user
  recipes = []
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

      ingredients_count = rand(2..3)
      units = [ 'cups', 'tablespoons', 'teaspoons', 'oz', 'grams', 'lbs' ]
      ingredients = ingredients_count.times.map do
        {
          name: Faker::Food.ingredient,
          amount: "#{rand(2..4)} #{units.sample}"
        }
      end

      recipe.recipe_items.build(ingredients)
      recipe.save!
      recipes << recipe

      puts "   🍳 Created recipe '#{recipe.name}' with #{ingredients_count} ingredients"
    rescue => e
      puts "   ❌ Failed to create recipe: #{e.message}"
    end
  end

  # Select 2–5 random recipes for pantry item matching
  selected_recipes = recipes.sample(rand(2..5))
  puts "   📋 Selected #{selected_recipes.size} recipes for pantry item matching"

  # Collect all recipe items from selected recipes
  matching_recipe_items = selected_recipes.flat_map do |recipe|
    recipe.recipe_items.map do |item|
      { name: item.name, amount: item.amount, unit: item.amount.split.last }
    end
  end.uniq { |item| [ item[:name], item[:unit] ] } # Ensure unique name-unit pairs

  # Create pantry items that match recipe items
  matching_recipe_items.each do |item|
    begin
      recipe_amount = item[:amount].split.first.to_f
      pantry_quantity = "#{rand((recipe_amount * 1.5).to_i..10)} #{item[:unit]}"

      pantry_item = PantryItem.create!(
        user: user,
        name: item[:name],
        barcode: Faker::Barcode.unique.ean(13),
        quantity: pantry_quantity
      )
      puts "   🥫 Created pantry item '#{pantry_item.name}' (#{pantry_item.quantity}) matching recipe for #{user.email}"
    rescue => e
      puts "   ❌ Failed to create pantry item: #{e.message}"
    end
  end

  # Fill the rest of the pantry with random items
  target_pantry_items = rand(75..100)
  remaining_items = [ target_pantry_items - matching_recipe_items.size, 0 ].max
  remaining_items.times do
    begin
      pantry_item = PantryItem.create!(
        user: user,
        name: Faker::Food.ingredient,
        barcode: Faker::Barcode.unique.ean(13),
        quantity: "#{rand(3..5)} #{[ 'cups', 'tablespoons', 'teaspoons', 'oz', 'grams', 'lbs' ].sample}"
      )
      puts "   🥫 Created pantry item '#{pantry_item.name}' for #{user.email}"
    rescue => e
      puts "   ❌ Failed to create pantry item: #{e.message}"
    end
  end

  # Create 20 meals for each user
  20.times do |i|
    begin
      recipes = user.recipes.sample(rand(1..3))
      meal = Meal.create!(
        user: user,
        name: "#{Faker::Food.dish}",
        description: Faker::Food.description,
        meal_type: Meal.meal_types.keys.sample,
        sharable: [ true, false ].sample
      )

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
puts "   Total pantry items: #{PantryItem.count}"
puts "   Total recipes: #{Recipe.count}"
puts "   Total recipe items: #{RecipeItem.count}"
puts "   Total meals: #{Meal.count}"
