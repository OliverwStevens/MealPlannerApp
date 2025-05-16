class MealPlansController < ApplicationController
  before_action :authenticate_user!

  def index
    # Always ensure we're starting from the beginning of a week, regardless of which date is selected
    selected_date = params[:start_date] ? Date.parse(params[:start_date]) : Date.current
    @start_date = selected_date.beginning_of_week
    @end_date = @start_date.end_of_week

    # Load existing meal plans with their meal types
    @meal_plans = current_user.meal_plans
                     .joins(:meal)
                     .where(date: @start_date..@end_date)
                     .select("meal_plans.*, meals.meal_type as meal_meal_type")
                     .group_by { |mp| [ mp.date, mp.meal_meal_type ] }

    @days = (@start_date..@end_date).to_a
    @meal_types = Meal.meal_types.keys

    @todays_meals = current_user.meal_plans
    .includes(:meal)
    .where(date: Date.today)
    .index_by { |plan| plan.meal.meal_type }
    # Initialize empty hash for each meal type
    @meals_by_type = Hash.new { |h, k| h[k] = [] }
    current_user.meals.each { |meal| @meals_by_type[meal.meal_type] << meal }
  end

  def create_or_update
    date = Date.parse(params[:date])
    meal_type = params[:meal_type]
    meal_id = params[:meal_id]

    # Find by date and meal type through the associated meal
    meal_plan = current_user.meal_plans
                  .includes(:meal)
                  .find { |mp| mp.date == date && mp.meal.meal_type == meal_type }

    # If not found, initialize a new one
    meal_plan ||= current_user.meal_plans.new(date: date)

    if meal_id.present?
      meal_plan.meal_id = meal_id
      if meal_plan.save
        redirect_to meal_plans_path(start_date: date.beginning_of_week), notice: "Meal plan updated!"
      else
        redirect_to meal_plans_path(start_date: date.beginning_of_week), alert: "Failed to update: #{meal_plan.errors.full_messages.join(', ')}"
      end
    else
      meal_plan.destroy if meal_plan.persisted?
      redirect_to meal_plans_path(start_date: date.beginning_of_week), notice: "Meal removed from plan"
    end
  end

  def auto_generate
    start_date = params[:start_date] ? Date.parse(params[:start_date]) : Date.current.beginning_of_week
    end_date = start_date.end_of_week
    days = (start_date..end_date).to_a
    meal_types = Meal.meal_types.keys

    # Get all available meals by type
    meals_by_type = Hash.new { |h, k| h[k] = [] }
    current_user.meals.each { |meal| meals_by_type[meal.meal_type] << meal }

    # Create a more reliable way to track filled slots
    # This approach directly checks for existing combinations in the database
    filled_slots = {}

    # First, load all meal plans for this date range
    existing_plans = current_user.meal_plans
                      .includes(:meal)
                      .where(date: start_date..end_date)

    # Create a lookup hash for filled slots
    existing_plans.each do |plan|
      # Use both date and meal type to create a unique key
      key = "#{plan.date}_#{plan.meal.meal_type}"
      filled_slots[key] = true
    end

    # Generate missing meal plans
    generated_count = 0
    days.each do |day|
      meal_types.each do |meal_type|
        # Create a lookup key matching the format we used above
        slot_key = "#{day}_#{meal_type}"

        # Skip if this slot is already filled
        next if filled_slots[slot_key]

        # Skip if no meals are available for this meal type
        next if meals_by_type[meal_type].empty?

        # Randomly select a meal for this slot
        random_meal = meals_by_type[meal_type].sample

        # Create a new meal plan
        meal_plan = current_user.meal_plans.new(date: day, meal_id: random_meal.id)
        if meal_plan.save
          generated_count += 1
          # Mark this slot as filled to prevent duplicates if there's an error later
          filled_slots[slot_key] = true
        end
      end
    end

    if generated_count > 0
      redirect_to meal_plans_path(start_date: start_date), notice: "Successfully generated #{generated_count} meal plans!"
    else
      redirect_to meal_plans_path(start_date: start_date), notice: "No meal plans needed to be generated!"
    end
  end

  def clear_week
    start_date = params[:start_date] ? Date.parse(params[:start_date]) : Date.current.beginning_of_week
    end_date = start_date.end_of_week

    # Find all meal plans for the current week
    meal_plans = current_user.meal_plans.where(date: start_date..end_date)

    # Count how many are being deleted
    count = meal_plans.count

    # Delete them all
    meal_plans.destroy_all

    redirect_to meal_plans_path(start_date: start_date), notice: "Cleared #{count} meal plans from your week!"
  end

  def generate_from_pantry
    @aggregated_pantry_items = IngredientAggregatorService.aggregate(current_user.pantry_items)
    @calculated_pantry_items = MetricConversionService.convert_hash_to_metric(@aggregated_pantry_items)

    @calculated_recipes = RecipesFromPantryService.pantry_to_recipes(@calculated_pantry_items, current_user.recipes)

    @recipes = current_user.recipes.where(id: @calculated_recipes.keys)
                           .sort_by { |r| -@calculated_recipes[r.id].to_i }
  end
end
