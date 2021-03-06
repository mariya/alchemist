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

ActiveRecord::Schema.define(:version => 20120214174910) do

  create_table "active_admin_comments", :force => true do |t|
    t.integer  "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "admin_users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

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

  create_table "industry_categories_nace_codes", :id => false, :force => true do |t|
    t.integer "industry_category_id", :null => false
    t.integer "nace_code_id",         :null => false
  end

  create_table "industry_presences", :force => true do |t|
    t.integer  "municipality_id",              :null => false
    t.integer  "nace_code_id",                 :null => false
    t.integer  "num_companies_with_employees", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "inputs", :id => false, :force => true do |t|
    t.integer "industrial_process_id",                  :null => false
    t.integer "resource_id",                            :null => false
    t.float   "quantity",              :default => 0.0, :null => false
  end

  create_table "intramunicipal_connections", :force => true do |t|
    t.string   "municipality_name",       :null => false
    t.string   "resource_name",           :null => false
    t.string   "industrial_process_name", :null => false
    t.string   "industry_category_name",  :null => false
    t.integer  "input_nace_code",         :null => false
    t.integer  "output_nace_code",        :null => false
    t.float    "factor",                  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "intramunicipal_connections", ["industrial_process_name"], :name => "index_intramunicipal_connections_on_industrial_process_name"
  add_index "intramunicipal_connections", ["industry_category_name"], :name => "index_intramunicipal_connections_on_industry_category_name"
  add_index "intramunicipal_connections", ["input_nace_code"], :name => "index_intramunicipal_connections_on_input_nace_code"
  add_index "intramunicipal_connections", ["municipality_name"], :name => "index_intramunicipal_connections_on_municipality_name"
  add_index "intramunicipal_connections", ["output_nace_code"], :name => "index_intramunicipal_connections_on_output_nace_code"
  add_index "intramunicipal_connections", ["resource_name"], :name => "index_intramunicipal_connections_on_resource_name"

  create_table "municipalities", :force => true do |t|
    t.string   "name",                                     :null => false
    t.string   "country",                                  :null => false
    t.string   "administrative_id"
    t.float    "latitude",                                 :null => false
    t.float    "longitude",                                :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "num_connections",         :default => 0,   :null => false
    t.float    "mean_connections_factor", :default => 0.0, :null => false
  end

  create_table "nace_codes", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nace_codes_resource_categories", :id => false, :force => true do |t|
    t.integer "nace_code_id",         :null => false
    t.integer "resource_category_id", :null => false
  end

  create_table "nace_codes_resources", :id => false, :force => true do |t|
    t.integer "nace_code_id", :null => false
    t.integer "resource_id",  :null => false
  end

  create_table "outputs", :force => true do |t|
    t.integer  "industry_category_id",          :null => false
    t.integer  "resource_category_id",          :null => false
    t.integer  "tons_non_hazardous_waste_2008", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.text     "body"
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
