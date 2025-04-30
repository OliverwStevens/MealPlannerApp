class HomeController < ApplicationController
  def index
    @public_recipes = Recipe.sharable
    # @public_meals = Meal.sharable
  end

  def show
    @public_recipe = Recipe.sharable.find(params[:id])
    # @public_meal = Meal.sharable.find(params[:id])
  end
end
