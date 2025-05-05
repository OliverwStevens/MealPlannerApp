class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates :first_name, :last_name, presence: true

  has_many :pantry_items, dependent: :destroy
  has_many :recipes, dependent: :destroy
  has_many :meals, dependent: :destroy
  has_many :meal_plans, dependent: :destroy

  def name
    "#{first_name} #{last_name}"
  end
end
