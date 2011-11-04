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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111104122324) do

  create_table "industrial_processes", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "industrial_processes_nace_codes", :id => false, :force => true do |t|
    t.integer "industrial_process_id", :null => false
    t.integer "nace_code_id",          :null => false
  end

  create_table "industry_categories", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "industry_presences", :force => true do |t|
    t.integer  "municipality_id",              :null => false
    t.integer  "nace_code_id",                 :null => false
    t.integer  "num_companies_with_employees", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "municipalities", :force => true do |t|
    t.string   "name",              :null => false
    t.string   "country",           :null => false
    t.string   "administrative_id"
    t.float    "latitude",          :null => false
    t.float    "longitude",         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nace_codes", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resource_categories", :force => true do |t|
    t.string   "name"
    t.string   "ewc_name"
    t.string   "ancestry"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resource_categories_resources", :id => false, :force => true do |t|
    t.integer "resource_category_id", :null => false
    t.integer "resource_id",          :null => false
  end

  create_table "resources", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
