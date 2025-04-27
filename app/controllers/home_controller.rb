class HomeController < ApplicationController
  def index
    @public_recipes = Recipe.sharable
  end

  def show
    @public_recipe = Recipe.sharable.find(params[:id])
  end
end
