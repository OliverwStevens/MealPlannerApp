require 'rails_helper'

RSpec.describe MealPlansHelper, type: :helper do
  describe '#meal_type_options' do
    it 'returns all meal types capitalized for select options' do
      # Stub the Meal.meal_types to ensure consistent testing
      allow(Meal).to receive(:meal_types).and_return({
        'breakfast' => 0,
        'lunch' => 1,
        'dinner' => 2,
        'snack' => 3
      })

      expected_result = [
        [ 'Breakfast', 'breakfast' ],
        [ 'Lunch', 'lunch' ],
        [ 'Dinner', 'dinner' ],
        [ 'Snack', 'snack' ]
      ]

      expect(helper.meal_type_options).to eq(expected_result)
    end

    it 'handles empty meal types' do
      allow(Meal).to receive(:meal_types).and_return({})
      expect(helper.meal_type_options).to eq([])
    end
  end

  describe '#week_dates' do
    let(:monday) { Date.new(2023, 6, 5) } # Monday, June 5, 2023

    it 'returns an array of dates for the week starting from the given date' do
      expected_dates = [
        Date.new(2023, 6, 5), # Monday
        Date.new(2023, 6, 6), # Tuesday
        Date.new(2023, 6, 7), # Wednesday
        Date.new(2023, 6, 8), # Thursday
        Date.new(2023, 6, 9), # Friday
        Date.new(2023, 6, 10), # Saturday
        Date.new(2023, 6, 11)  # Sunday
      ]

      expect(helper.week_dates(monday)).to eq(expected_dates)
    end

    it 'returns correct dates when given a mid-week date' do
      wednesday = Date.new(2023, 6, 7)
      expect(helper.week_dates(wednesday).first).to eq(monday)
      expect(helper.week_dates(wednesday).last).to eq(Date.new(2023, 6, 11))
    end

    it 'returns 7 days for any input date' do
      random_dates = [ Date.today, Date.yesterday, Date.tomorrow, Date.new(2023, 12, 31) ]

      random_dates.each do |date|
        expect(helper.week_dates(date).size).to eq(7)
      end
    end
  end
end
