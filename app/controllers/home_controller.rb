class HomeController < ApplicationController
  def index
    @public_recipes = Recipe.sharable
    @public_meals = Meal.sharable
  end

  def show
    type = params[:type]
    id = params[:id]

    begin
      if type == "recipe"
        @public_item = Recipe.sharable.find(id)
      elsif type == "meal"
        @public_item = Meal.sharable.find(id)
      else
        raise ActiveRecord::RecordNotFound
      end
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = "The requested item could not be found."
      redirect_to root_path
    end
  end
end
