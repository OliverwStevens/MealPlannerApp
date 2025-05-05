# app/controllers/meal_plans_controller.rb
class MealPlansController < ApplicationController
  before_action :authenticate_user!

  def index
    @start_date = params[:start_date] ? Date.parse(params[:start_date]) : Date.current.beginning_of_week
    @end_date = @start_date.end_of_week
    @meal_plans = current_user.meal_plans.where(date: @start_date..@end_date).includes(:meal)
    @grouped_plans = @meal_plans.group_by(&:date)
  end

  def new
    @date = params[:date] ? Date.parse(params[:date]) : Date.current
    @meal_type = params[:meal_type]
    @meals = current_user.meals.where(meal_type: @meal_type)
    @meal_plan = current_user.meal_plans.new(date: @date)
  end

  def create
    @meal_plan = current_user.meal_plans.new(meal_plan_params)

    if @meal_plan.save
      redirect_to meal_plans_path, notice: "Meal added to plan successfully."
    else
      # Re-fetch the meal type from params if save fails
      @meal_type = params[:meal_type]
      @meals = current_user.meals.where(meal_type: @meal_type)
      render :new
    end
  end

  def destroy
    @meal_plan = current_user.meal_plans.find(params[:id])
    @meal_plan.destroy
    redirect_to meal_plans_path, notice: "Meal removed from plan."
  end

  private

  def meal_plan_params
    params.require(:meal_plan).permit(:date, :meal_id)
  end
end
