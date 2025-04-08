class OpenFoodFactsService
  include HTTParty
  base_uri "https://world.openfoodfacts.org/api/v0/product"

  def self.fetch_product(barcode)
    response = get("/#{barcode}.json")

    if response.success?
      process_api_response(response.parsed_response)
    else
      { error: "API request failed: #{response.code}" }
    end
  rescue StandardError => e
    { error: e.message }
  end

  private

  def self.process_api_response(data)
    if data["status"] == 1 && data["product"]
      product = data["product"]
      {
        name: product["product_name"] || "No name available",
        ingredients: product["ingredients_text"] || "No ingredients listed",
        # nutrients: product["nutriments"] || {},
        image_url: product["image_url"]
      }
    else
      { error: "Product not found in database" }
    end
  end
end
