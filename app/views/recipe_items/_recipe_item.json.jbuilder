json.extract! recipe_item, :id, :recipe_id, :name, :amount, :created_at, :updated_at
json.url recipe_item_url(recipe_item, format: :json)
