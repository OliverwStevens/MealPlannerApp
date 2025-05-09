class RecipesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_recipe, only: [ :show, :edit, :update, :destroy ]
  # GET /recipes or /recipes.json
  def index
    @recipes = current_user.recipes.order(:name).page(params[:page]).per(12)
    @total_recipes_count = current_user.recipes.count


    if request.headers["Turbo-Frame"] || request.xhr?
      render partial: "index", locals: { recipes: @recipes }
    end
  end

  # GET /recipes/1 or /recipes/1.json
  def show
  end

  # GET /recipes/new
  def new
    @recipe = current_user.recipes.new
  end

  # GET /recipes/1/edit
  def edit
  end

  # POST /recipes or /recipes.json
  def create
    @recipe = current_user.recipes.new(recipe_params)

    respond_to do |format|
      if @recipe.save
        format.html { redirect_to @recipe, notice: "Recipe was successfully created." }
        format.json { render :show, status: :created, location: @recipe }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @recipe.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /recipes/1 or /recipes/1.json
  def update
    respond_to do |format|
      if @recipe.update(recipe_params)
        format.html { redirect_to @recipe, notice: "Recipe was successfully updated." }
        format.json { render :show, status: :ok, location: @recipe }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @recipe.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /recipes/1 or /recipes/1.json
  def destroy
    @recipe.destroy!

    respond_to do |format|
      format.html { redirect_to recipes_path, status: :see_other, notice: "Recipe was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def add
    public_recipe = Recipe.find(params[:id])

    # Check if current user already has this recipe
    if current_user.recipes.exists?(public_recipe.id)
      redirect_to recipes_path, alert: "This recipe is already in your collection."
    else
      attributes = public_recipe.attributes.except("id", "created_at", "updated_at", "user_id")
      attributes["sharable"] = false
      attributes["recipe_items"] = public_recipe.recipe_items
      new_recipe = current_user.recipes.new(attributes)
      if new_recipe.save
        redirect_to recipes_path, notice: "Recipe successfully added to your collection."
      else

        redirect_to recipes_path(public_recipe), notice: "Could not add recipe: #{new_recipe.errors.full_messages.join(', ')}"
      end
    end
  end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_recipe
      @recipe = current_user.recipes.find(params[:id])
    end

    def recipe_params
      permitted_params =params.require(:recipe).permit(
        :name, :procedure, :servings, :difficulty, :prep_time, :recipe_type, :diet, :sharable, :image,
        recipe_items_attributes: [ :id, :name, :amount, :_destroy ]
      )
      permitted_params = permitted_params.merge(user_id: current_user.id)
    end
end
