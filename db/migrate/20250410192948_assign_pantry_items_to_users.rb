class AssignPantryItemsToUsers < ActiveRecord::Migration[7.0]
  def up
    # Assign all existing items to the first user (or another logic)
    user = User.first
    PantryItem.update_all(user_id: user.id) if user
  end

  def down
    PantryItem.update_all(user_id: nil)
  end
end
