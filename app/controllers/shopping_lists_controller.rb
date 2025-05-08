class ShoppingListsController < ApplicationController
  before_action :authenticate_user!

  def index
    # Get date range from params or default to current week
    @start_date = params[:start_date] ? Date.parse(params[:start_date]) : Date.current.beginning_of_week
    @end_date = @start_date.end_of_week

    # Load meal plans for the selected date range
    @meal_plans = current_user.meal_plans
                    .includes(meal: { recipes: :recipe_items })
                    .where(date: @start_date..@end_date)

    # Group meal plans by date
    @meal_plans_by_date = @meal_plans.group_by(&:date)

    # Collect all recipe items across all meals in the meal plan
    @all_recipe_items = collect_recipe_items(@meal_plans)

    # Process and aggregate ingredients using the service object
    @aggregated_ingredients = IngredientAggregatorService.aggregate(@all_recipe_items)
  end

  private

  def collect_recipe_items(meal_plans)
    recipe_items = []
    meal_plans.each do |meal_plan|
      meal_plan.meal.recipes.each do |recipe|
        recipe.recipe_items.each do |item|
          recipe_items << item
        end
      end
    end
    recipe_items
  end
end
