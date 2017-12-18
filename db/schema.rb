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

ActiveRecord::Schema.define(version: 20171215081446) do

  create_table "cards", force: :cascade do |t|
    t.integer "megami_code"
    t.string "megami_name"
    t.string "megami_fullname"
    t.string "code"
    t.string "name"
    t.string "main_type"
    t.string "sub_type"
    t.string "kasa"
    t.string "range"
    t.string "damage_aura"
    t.string "damage_life"
    t.string "osame"
    t.string "cost"
    t.text "description"
  end

end
