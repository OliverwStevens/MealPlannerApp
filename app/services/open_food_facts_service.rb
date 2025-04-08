class OpenFoodFactsService
  include HTTParty
  base_uri "https://world.openfoodfacts.org/api/v0/product"
  format :json

  # Cache wrapper with error handling
  def self.fetch_product(barcode)
    Rails.cache.fetch(cache_key(barcode), expires_in: 12.hours) do
      fetch_from_api(barcode)
    end
  rescue StandardError => e
    log_error("Cache failure for #{barcode}: #{e.message}")
    fetch_from_api(barcode) # Fallback to direct API call
  end

  private

  def self.cache_key(barcode)
    "off/v1/#{barcode}" # Versioned cache key for future migrations
  end

  def self.fetch_from_api(barcode)
    response = get("/#{barcode}.json")

    if response.success?
      process_response(response.parsed_response)
    else
      log_error("API request failed: #{response.code} - #{response.body}")
      { error: "Product not found", api_status: response.code }
    end
  rescue HTTParty::Error, SocketError => e
    log_error("Network error: #{e.message}")
    { error: "Service unavailable", retry_after: 60 }
  end

  def self.process_response(data)
    if data["status"] == 1 && data["product"]
      product = data["product"]
      {
        name: product["product_name"].presence || "Untitled Product",
        ingredients: product["ingredients_text"].presence || "No ingredients listed",
        # nutrients: product["nutriments"] || {},
        image_url: product["image_url"],
        cached_at: Time.current # Helpful for debugging
      }
    else
      { error: "Invalid product data", api_status: data["status"] }
    end
  end

  def self.log_error(message)
    Rails.logger.error("[OpenFoodFactsService] #{message}")
    # Consider adding error tracking (Sentry, Rollbar, etc.)
  end
end
