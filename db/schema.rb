# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_04_28_180434) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "meal_recipes", force: :cascade do |t|
    t.bigint "meal_id", null: false
    t.bigint "recipe_id", null: false
    t.integer "position"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["meal_id", "recipe_id"], name: "index_meal_recipes_on_meal_id_and_recipe_id", unique: true
    t.index ["meal_id"], name: "index_meal_recipes_on_meal_id"
    t.index ["recipe_id"], name: "index_meal_recipes_on_recipe_id"
  end

  create_table "meals", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_meals_on_user_id"
  end

  create_table "pantry_items", force: :cascade do |t|
    t.string "name"
    t.string "barcode"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "img_url"
    t.index ["user_id"], name: "index_pantry_items_on_user_id"
  end

  create_table "recipe_items", force: :cascade do |t|
    t.bigint "recipe_id", null: false
    t.string "name"
    t.string "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id"], name: "index_recipe_items_on_recipe_id"
  end

  create_table "recipes", force: :cascade do |t|
    t.string "name"
    t.text "procedure"
    t.integer "servings"
    t.integer "difficulty"
    t.string "prep_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "recipe_type"
    t.string "diet"
    t.bigint "user_id", null: false
    t.boolean "sharable"
    t.index ["user_id"], name: "index_recipes_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "meal_recipes", "meals"
  add_foreign_key "meal_recipes", "recipes"
  add_foreign_key "meals", "users"
  add_foreign_key "pantry_items", "users"
  add_foreign_key "recipe_items", "recipes"
  add_foreign_key "recipes", "users"
end
