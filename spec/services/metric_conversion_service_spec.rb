require 'rails_helper'

RSpec.describe MetricConversionService, type: :service do
  describe ".convert_to_metric" do
    it "converts units correctly" do
      items = [
        { water: "6 ml" },
        { Oranges: "3 oz" },
        { Sugar: "2 cups" },
        { Chocolate: "1 package" },
        { mint: "6 sprigs" },
        { Milk: "8 gallons" }
      ]

      expected_result = [
        { water: "6.0 ml" },
        { Oranges: "85.05 g" },
        { Sugar: "473.18 ml" }, # assuming cups are now volume-based
        { Chocolate: "1 package" },
        { mint: "6 sprigs" },
        { Milk: "30283.28 ml" }
      ]

      result = MetricConversionService.convert_to_metric(items)
      expect(result).to eq(expected_result)
    end
  end
end
