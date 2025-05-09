class SearchController < ApplicationController
  def index
    if params[:query].present?
      # Perform searches
      recipe_results = Recipe.search(params[:query],
                      where: { sharable: true },
                      fields: [ :name ],
                      load: false)

      meal_results = Meal.search(params[:query],
                    where: { sharable: true },
                    fields: [ :name, :description ],
                    load: false)

      # Get the actual records from the search results
      recipe_ids = recipe_results.map(&:id)
      meal_ids = meal_results.map(&:id)

      # Fetch the actual records
      recipes = Recipe.where(id: recipe_ids, sharable: true)
      meals = Meal.where(id: meal_ids, sharable: true)

      # Get the created_at times for sorting
      recipe_times = {}
      meal_times = {}

      recipe_results.each do |result|
        recipe_times[result.id.to_s] = result.created_at
      end

      meal_results.each do |result|
        meal_times[result.id.to_s] = result.created_at
      end

      # Combine and sort all items
      combined_items = (recipes.to_a + meals.to_a)

      # Sort by created_at from search results
      sorted_items = combined_items.sort_by do |item|
        if item.is_a?(Recipe)
          -recipe_times[item.id.to_s].to_i
        else
          -meal_times[item.id.to_s].to_i
        end
      end

      # Paginate the sorted items
      @search_items = Kaminari.paginate_array(sorted_items).page(params[:page]).per(24)

      @total_items_count = sorted_items.count
      if request.headers["Turbo-Frame"] || request.xhr?
        render partial: "index", locals: { search_items: @search_items }
      end
    else
      @search_items = Kaminari.paginate_array([]).page(params[:page]).per(24)
    end
  end
end
