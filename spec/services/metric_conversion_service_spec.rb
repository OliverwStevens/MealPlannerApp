require 'rails_helper'

RSpec.describe MetricConversionService, type: :service do
  describe ".convert_hash_to_metric" do
    it "converts and aggregates units correctly" do
      items = {
        water: "6 ml",
        Oranges: "3 oz",
        Sugar: "2 cups",
        Chocolate: "1 package",
        mint: "6 sprigs",
        Milk: "8 gallons"
      }

      expected_result = {
        water: "6.0 ml",
        Oranges: "85.05 g",
        Sugar: "473.18 ml",
        Chocolate: "1 package",
        mint: "6 sprigs",
        Milk: "30283.28 ml"
      }

      result = MetricConversionService.convert_hash_to_metric(items)

      expect(result).to eq(expected_result)
    end
  end

  describe ".subtract_hashes" do
    it "correctly calculates differences between hashes with various units" do
      hash1 = {
        "Papaya" => "56.7 g",
        "Pasta" => "473.18 ml",
        "Swiss Chard" => "44.36 ml",
        "Fennel" => "1 package",
        "Oranges" => "2 oz",
        "Honey" => "3 tbsp"
      }

      hash2 = {
        "Papaya" => "640.0 g",
        "Pasta" => "53.18 ml",
        "Swiss Chard" => "4.36 ml",
        "Fennel" => "3 packages",
        "Oranges" => "5 oz",
        "Honey" => "100 ml",
        "Chocolate" => "2 bars"
      }

      expected_result = {
        "Papaya" => "583.3 g",
        "Pasta" => "-420.0 ml",
        "Swiss Chard" => "-40.0 ml",
        "Fennel" => "2 packages",
        "Oranges" => "85.05 g",
        "Honey" => "55.64 ml",
        "Chocolate" => "2 bars"
      }

      result = MetricConversionService.subtract_hashes(hash1, hash2)

      expect(result).to eq(expected_result)
    end

    it "handles edge cases with empty hashes and matching values" do
      hash1 = {
        "Sugar" => "500 g",
        "Milk" => "1 cup",
        "Eggs" => "12 pieces"
      }

      hash2 = {
        "Sugar" => "500 g",
        "Milk" => "236.588 ml",  # Exactly 1 cup in ml
        "Flour" => "2 cups"
      }

      expected_result = {
        "Flour" => "2 cups"
      }

      result = MetricConversionService.subtract_hashes(hash1, hash2)

      expect(result).to eq(expected_result)
    end
  end
end
