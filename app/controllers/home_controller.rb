class HomeController < ApplicationController
  def index
    @public_recipes = Recipe.sharable
  end
end
