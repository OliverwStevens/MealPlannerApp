class HomeController < ApplicationController
def index
  recipes = Recipe.sharable
  meals = Meal.sharable

  # Combine and sort by creation date
  @combined_feed = (recipes + meals).sort_by(&:created_at).reverse
  @items = Kaminari.paginate_array(@combined_feed).page(params[:page]).per(24)
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
