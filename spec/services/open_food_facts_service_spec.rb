require 'rails_helper'

RSpec.describe OpenFoodFactsService, type: :service do
  let(:barcode) { '1234567890' }
  let(:cache_key) { "off/v1/#{barcode}" }
  let(:product_data) do
    {
      "status" => 1,
      "product" => {
        "product_name" => "Test Product",
        "quantity" => "5 g",
        "image_front_small_url" => "http://example.com/image.jpg"
      }
    }
  end

  describe '.fetch_product' do
    context 'when data is in cache' do
      it 'returns cached data' do
        # Mock Rails.cache.fetch to return the product data
        cached_response = { name: "Test Product", ingredients: "Sugar, Salt", img_url: "http://example.com/image.jpg", cached_at: Time.current }
        allow(Rails.cache).to receive(:fetch).with(cache_key, expires_in: 12.hours).and_return(cached_response)

        response = OpenFoodFactsService.fetch_product(barcode)

        expect(response[:name]).to eq("Test Product")
        expect(response[:ingredients]).to eq("Sugar, Salt")
        expect(response[:img_url]).to eq("http://example.com/image.jpg")
      end
    end

    context 'when data is not in cache and API is called' do
      it 'fetches data from the API and caches it' do
        # Mock Rails.cache.fetch to call the block and return fresh data
        allow(Rails.cache).to receive(:fetch).with(cache_key, expires_in: 12.hours).and_yield
        # Mock the API call (HTTParty.get)
        allow(OpenFoodFactsService).to receive(:get).with("/#{barcode}.json").and_return(double(success?: true, parsed_response: product_data))

        response = OpenFoodFactsService.fetch_product(barcode)

        expect(response[:name]).to eq("Test Product")
        expect(response[:quantity]).to eq("5 g")
        expect(response[:img_url]).to eq("http://example.com/image.jpg")
        expect(Rails.cache).to have_received(:fetch).with(cache_key, expires_in: 12.hours)
      end
    end

    context 'when API call fails' do
      it 'returns an error message when the API call fails' do
        # Mock the API call to simulate failure
        allow(OpenFoodFactsService).to receive(:get).with("/#{barcode}.json").and_return(double(success?: false, code: 404, body: "Not found"))

        response = OpenFoodFactsService.fetch_product(barcode)

        expect(response[:error]).to eq("Product not found")
        expect(response[:api_status]).to eq(404)
      end
    end

    context 'when there is a network error' do
      it 'returns a service unavailable error' do
        # Simulate a network error
        allow(OpenFoodFactsService).to receive(:get).with("/#{barcode}.json").and_raise(SocketError)

        response = OpenFoodFactsService.fetch_product(barcode)

        expect(response[:error]).to eq("Service unavailable")
        expect(response[:retry_after]).to eq(60)
      end
    end

    context 'when the API returns invalid data' do
      it 'returns an error message if the product data is invalid' do
        invalid_product_data = {
          "status" => 0, # invalid status
          "product" => nil
        }
        # Mock the API call to return invalid data
        allow(OpenFoodFactsService).to receive(:get).with("/#{barcode}.json").and_return(double(success?: true, parsed_response: invalid_product_data))

        response = OpenFoodFactsService.fetch_product(barcode)

        expect(response[:error]).to eq("Invalid product data")
        expect(response[:api_status]).to eq(0)
      end
    end
  end

  describe '.log_error' do
    it 'logs an error message' do
      # Mock the Rails logger
      allow(Rails.logger).to receive(:error)

      OpenFoodFactsService.log_error("Test error")

      expect(Rails.logger).to have_received(:error).with("[OpenFoodFactsService] Test error")
    end
  end
end
