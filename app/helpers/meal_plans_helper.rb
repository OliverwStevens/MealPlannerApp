module MealPlansHelper
  def meal_type_options
    Meal.meal_types.keys.map { |type| [ type.capitalize, type ] }
  end

  def week_dates(start_date)
    (start_date.beginning_of_week..start_date.end_of_week).to_a
  end
end
