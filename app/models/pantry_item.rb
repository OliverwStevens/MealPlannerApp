class PantryItem < ApplicationRecord
  validates :barcode, :user_id, presence: true
  belongs_to :user

  def amount_value
    quantity
  end
end
