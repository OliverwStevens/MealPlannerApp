class PantryItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_pantry_item, only: %i[ show edit update destroy ]

  # GET /pantry_items or /pantry_items.json
  def index
    @pantry_items = PantryItem.all
  end

  # GET /pantry_items/1 or /pantry_items/1.json
  def show
    Rails.logger.warn("Barcode from DB: #{@pantry_item.barcode}")
    if @pantry_item.barcode.present?
      @product_data = OpenFoodFactsService.fetch_product(@pantry_item.barcode)

      Rails.logger.warn(@product_data[:name])
    else
      Rails.logger.warn("No barcode in database record")
      @product_data = { error: "No barcode provided" }
    end
  end

  # GET /pantry_items/new
  def new
    @pantry_item = PantryItem.new
  end

  # GET /pantry_items/1/edit
  def edit
  end

  # POST /pantry_items or /pantry_items.json
  def create
    Rails.logger.info "Params received: #{params.inspect}"
    @pantry_item = PantryItem.new(pantry_item_params)

    respond_to do |format|
      if @pantry_item.save
        format.html { redirect_to @pantry_item, notice: "Pantry item was successfully created." }
        format.json { render :show, status: :created, location: @pantry_item }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @pantry_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pantry_items/1 or /pantry_items/1.json
  def update
    respond_to do |format|
      if @pantry_item.update(pantry_item_params)
        format.html { redirect_to @pantry_item, notice: "Pantry item was successfully updated." }
        format.json { render :show, status: :ok, location: @pantry_item }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @pantry_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pantry_items/1 or /pantry_items/1.json
  def destroy
    @pantry_item.destroy!

    respond_to do |format|
      format.html { redirect_to pantry_items_path, status: :see_other, notice: "Pantry item was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pantry_item
      @pantry_item = PantryItem.find(params.require(:id))
    end

    # Only allow a list of trusted parameters through.
    def pantry_item_params
      params.require(:pantry_item).permit(:name, :barcode, :quantity).merge(user_id: current_user.id)
    end
end
