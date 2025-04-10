class PantryItem < ApplicationRecord
  validates :barcode, :user_id, presence: true
  belongs_to :user
end
