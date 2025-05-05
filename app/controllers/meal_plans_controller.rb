# app/controllers/meal_plans_controller.rb
class MealPlansController < ApplicationController
  before_action :authenticate_user!

  def index
    @start_date = params[:start_date] ? Date.parse(params[:start_date]) : Date.current.beginning_of_week
    @end_date = @start_date.end_of_week

    # Load existing meal plans with their meal types
    @meal_plans = current_user.meal_plans
                     .joins(:meal)
                     .where(date: @start_date..@end_date)
                     .select("meal_plans.*, meals.meal_type as meal_meal_type")
                     .group_by { |mp| [ mp.date, mp.meal_meal_type ] }

    @days = (@start_date..@end_date).to_a
    @meal_types = Meal.meal_types.keys

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
        redirect_to meal_plans_path, notice: "Meal plan updated!"
      else
        redirect_to meal_plans_path, alert: "Failed to update: #{meal_plan.errors.full_messages.join(', ')}"
      end
    else
      meal_plan.destroy if meal_plan.persisted?
      redirect_to meal_plans_path, notice: "Meal removed from plan"
    end
  end
end
