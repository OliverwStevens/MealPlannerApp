json.extract! recipe, :id, :name, :procedure, :servings, :difficulty, :prep_time, :created_at, :updated_at
json.url recipe_url(recipe, format: :json)
