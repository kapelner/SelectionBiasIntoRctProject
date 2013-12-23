# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20121115021023) do

  create_table "admins", :force => true do |t|
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
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "admins", ["email"], :name => "index_admins_on_email", :unique => true
  add_index "admins", ["reset_password_token"], :name => "index_admins_on_reset_password_token", :unique => true

  create_table "big_brother_params", :force => true do |t|
    t.string  "param"
    t.text    "value"
    t.integer "big_brother_track_id"
  end

  add_index "big_brother_params", ["big_brother_track_id"], :name => "index_big_brother_params_on_big_brother_track_id"

  create_table "big_brother_tracks", :force => true do |t|
    t.string   "mturk_worker_id"
    t.string   "ip"
    t.string   "controller"
    t.string   "action"
    t.string   "method"
    t.boolean  "ajax"
    t.datetime "created_at"
  end

  add_index "big_brother_tracks", ["mturk_worker_id"], :name => "index_big_brother_tracks_on_mturk_worker_id"

  create_table "demographics", :force => true do |t|
    t.string   "mturk_worker_id"
    t.integer  "age"
    t.string   "gender",                 :limit => 1
    t.string   "urban_rural",            :limit => 1
    t.string   "highest_education"
    t.string   "marital_status"
    t.string   "employment_status"
    t.integer  "num_children",           :limit => 2
    t.integer  "income"
    t.string   "religion"
    t.string   "belief_in_divine",       :limit => 1
    t.string   "race"
    t.string   "participate_in_study",   :limit => 1
    t.string   "born_here"
    t.string   "english_first_language"
    t.string   "nfc_1",                  :limit => 2
    t.string   "nfc_2",                  :limit => 2
    t.string   "big_5_1",                :limit => 2
    t.string   "big_5_2",                :limit => 2
    t.string   "big_5_3",                :limit => 2
    t.string   "big_5_4",                :limit => 2
    t.string   "big_5_5",                :limit => 2
    t.datetime "completed_at"
    t.datetime "created_at"
  end

  add_index "demographics", ["mturk_worker_id"], :name => "index_demographics_on_mturk_worker_id"

  create_table "rails_admin_histories", :force => true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      :limit => 2
    t.integer  "year",       :limit => 8
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], :name => "index_rails_admin_histories"

  create_table "saw_experiments", :force => true do |t|
    t.integer  "task_id"
    t.string   "mturk_worker_id"
    t.datetime "created_at"
  end

  add_index "saw_experiments", ["mturk_worker_id"], :name => "index_saw_experiments_on_mturk_worker_id"
  add_index "saw_experiments", ["task_id"], :name => "index_saw_experiments_on_task_id"

  create_table "splash_views", :force => true do |t|
    t.string   "ip_address"
    t.datetime "created_at"
  end

  add_index "splash_views", ["ip_address"], :name => "index_splash_views_on_ip_address"

  create_table "studies", :force => true do |t|
    t.integer  "task_id"
    t.string   "study_name"
    t.decimal  "response",          :precision => 20, :scale => 6
    t.datetime "responded_at"
    t.integer  "num_page_nav_away",                                :default => 0,     :null => false
    t.datetime "created_at"
    t.boolean  "outlier",                                          :default => false, :null => false
  end

  create_table "tasks", :force => true do |t|
    t.string   "mturk_hit_id"
    t.string   "mturk_group_id"
    t.integer  "version"
    t.float    "wage"
    t.datetime "to_be_expired_at"
    t.string   "country",             :limit => 2
    t.string   "mturk_assignment_id"
    t.string   "mturk_worker_id"
    t.string   "ip_address"
    t.datetime "started_at"
    t.text     "turker_comments"
    t.datetime "finished_at"
    t.string   "browser_info"
    t.datetime "rejected_at"
    t.datetime "paid_at"
    t.float    "bonus"
    t.text     "notes"
    t.integer  "current_study_num",   :limit => 3, :default => 0, :null => false
    t.text     "study_list"
    t.string   "exp_arm",             :limit => 1
    t.boolean  "treatment"
    t.integer  "num_page_reloads",                 :default => 0, :null => false
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
  end

  add_index "tasks", ["mturk_worker_id"], :name => "index_tasks_on_mturk_worker_id", :unique => true

end
