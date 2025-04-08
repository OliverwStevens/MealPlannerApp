class PantryItem < ApplicationRecord
  validates :barcode, presence: true
  belongs_to :user
end
