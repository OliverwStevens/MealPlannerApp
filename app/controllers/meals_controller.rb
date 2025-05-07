class MealsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_meal, only: %i[ show edit update destroy ]

  # GET /meals or /meals.json
  def index
    @meals = current_user.meals.order(:name).page params[:page]
  end

  # GET /meals/1 or /meals/1.json
  def show
  end

  # GET /meals/new
  def new
    @meal = current_user.meals.new
  end

  # GET /meals/1/edit
  def edit
  end

  # POST /meals or /meals.json
  def create
    @meal = current_user.meals.new(meal_params.except(:recipe_ids))


    respond_to do |format|
      if @meal.save
        @meal.recipe_ids = clean_recipe_ids(meal_params[:recipe_ids])
        format.html { redirect_to @meal, notice: "Meal was successfully created." }
        format.json { render :show, status: :created, location: @meal }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @meal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /meals/1 or /meals/1.json
  def update
    respond_to do |format|
      if @meal.update(meal_params)
        format.html { redirect_to @meal, notice: "Meal was successfully updated." }
        format.json { render :show, status: :ok, location: @meal }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @meal.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /meals/1 or /meals/1.json
  def destroy
    @meal.destroy!

    respond_to do |format|
      format.html { redirect_to meals_path, status: :see_other, notice: "Meal was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def add
    public_meal = Meal.find(params[:id])

    # Check if current user already has this meal
    if current_user.meals.exists?(public_meal.id)
      redirect_to meals_path, alert: "This meal is already in your collection."
    else
      begin
        # Start a transaction to ensure all operations succeed or fail together
        ActiveRecord::Base.transaction do
          # Create a new meal for the current user
          attributes = public_meal.attributes.except("id", "created_at", "updated_at", "user_id")
          attributes["sharable"] = false
          new_meal = current_user.meals.new(attributes)

          # Save the meal first without recipes
          new_meal.save!

          # Now handle each recipe and associate with the new meal
          public_meal.recipes.each do |public_recipe|
            # Find or create recipe based on recipe_uuid
            user_recipe = find_or_create_recipe_by_uuid(current_user, public_recipe)

            # Associate the recipe with the meal if not already associated
            new_meal.recipes << user_recipe unless new_meal.recipes.include?(user_recipe)
          end
        end

        redirect_to meals_path, notice: "Meal successfully added to your collection."
      rescue => e
        redirect_to meals_path, alert: "Error: #{e.message}"
      end
    end
  end

  private

  def set_meal
    @meal = current_user.meals.find(params[:id])
  end

  def clean_recipe_ids(ids)
    Array(ids).reject(&:blank?).map(&:to_i)
  end

  def meal_params
    params.require(:meal).permit(:name, :description, :meal_type, :image, :sharable, recipe_ids: [])
  end

  def find_or_create_recipe_by_uuid(user, public_recipe)
    # First try to find the exact same recipe if the user is the creator
    if public_recipe.user_id == user.id
      return public_recipe
    end

    # Look for a recipe with matching recipe_uuid
    # This assumes you have a recipe_uuid column in your recipes table
    matching_recipe = user.recipes.find_by(recipe_uuid: public_recipe.recipe_uuid)

    if matching_recipe
      matching_recipe
    else
      # Create a new copy of the recipe for the user
      recipe_attributes = public_recipe.attributes.except("id", "created_at", "updated_at", "user_id")
      recipe_attributes["sharable"] = false
      # Important: Keep the same recipe_uuid when copying
      # This ensures we can identify copies of the same recipe
      recipe_attributes["recipe_uuid"] = public_recipe.recipe_uuid

      new_recipe = user.recipes.new(recipe_attributes)

      # Copy recipe items
      public_recipe.recipe_items.each do |item|
        new_recipe.recipe_items.build(item.attributes.except("id", "created_at", "updated_at", "recipe_id"))
      end

      # Save the recipe
      new_recipe.save!

      new_recipe
    end
  end
end
