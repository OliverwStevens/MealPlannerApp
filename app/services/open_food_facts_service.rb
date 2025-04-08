class OpenFoodFactsService
  def self.fetch_product(barcode)
    product = Openfoodfacts::Product.get(barcode)

    if product && product.product_name.present?
      {
        name: product.product_name,
        ingredients: product.ingredients_text,
        nutrients: product.nutriments,
        image_url: product.image_url
      }
    else
      { error: "Product not found" }
    end
  rescue StandardError => e
    { error: e.message }
  end
end
