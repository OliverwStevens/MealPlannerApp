json.extract! pantry_item, :id, :name, :barcode, :user_id, :created_at, :updated_at
json.url pantry_item_url(pantry_item, format: :json)
