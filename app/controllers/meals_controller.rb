class MealsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_meal, only: %i[ show edit update destroy ]

  # GET /meals or /meals.json
  def index
    @meals = current_user.meals
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

  private

  def set_meal
    @meal = current_user.meals.find(params[:id])
  end

  def clean_recipe_ids(ids)
    Array(ids).reject(&:blank?).map(&:to_i)
  end

  def meal_params
    params.require(:meal).permit(:name, :description, :image, recipe_ids: [])
  end
end
