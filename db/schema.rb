# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_09_12_154538) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.index ["name"], name: "index_organizations_on_name", unique: true
  end

  create_table "recipes", force: :cascade do |t|
    t.bigint "organization_id"
    t.string "title", default: "", null: false
    t.string "description", default: ""
    t.string "content", default: ""
    t.string "pictureList", default: [], array: true
    t.integer "updated_by"
    t.index ["organization_id"], name: "index_recipes_on_organization_id"
    t.index ["title"], name: "index_recipes_on_title", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.bigint "organization_id"
    t.string "email"
    t.string "password"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["organization_id"], name: "index_users_on_organization_id"
  end

end
