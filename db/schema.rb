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

ActiveRecord::Schema.define(version: 10) do

  create_table "conferences", force: true do |t|
    t.string "name", limit: 100, null: false
  end

  create_table "elections", force: true do |t|
    t.integer  "event_id",                                  null: false
    t.string   "name",          limit: 255
    t.string   "type",          limit: 50
    t.text     "conditions"
    t.datetime "start_time"
    t.datetime "end_time"
    t.boolean  "auth_required",             default: false
  end

  add_index "elections", ["event_id"], name: "election_event_idx"
  add_index "elections", ["start_time", "end_time"], name: "election_times_idx"

  create_table "events", force: true do |t|
    t.string   "name",          limit: 100,                 null: false
    t.integer  "conference_id",                             null: false
    t.string   "location",      limit: 255
    t.datetime "start_time"
    t.datetime "end_time"
    t.text     "description"
    t.boolean  "active",                    default: false, null: false
  end

  add_index "events", ["active"], name: "event_active_idx"
  add_index "events", ["conference_id"], name: "event_conf_idx"
  add_index "events", ["start_time", "end_time"], name: "event_time_idx"

  create_table "items", force: true do |t|
    t.string  "name",        limit: 255,                null: false
    t.integer "event_id",                               null: false
    t.text    "description"
    t.boolean "active",                  default: true, null: false
    t.integer "election_id",             default: 0
  end

  add_index "items", ["active"], name: "item_active_idx"
  add_index "items", ["event_id"], name: "item_event_idx"

  create_table "participants", force: true do |t|
    t.integer "person_id",            null: false
    t.integer "item_id",              null: false
    t.string  "role",      limit: 25
  end

  add_index "participants", ["person_id", "item_id", "role"], name: "participant_role_idx"

  create_table "people", force: true do |t|
    t.string "username",     limit: 50
    t.string "first_name",   limit: 100
    t.string "middle_name",  limit: 100
    t.string "last_name",    limit: 100
    t.string "email",        limit: 255
    t.string "organization", limit: 255
    t.string "title",        limit: 255
  end

  add_index "people", ["username", "email"], name: "people_user_idx"

  create_table "sessions", force: true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at"

  create_table "votes", force: true do |t|
    t.integer  "election_id",             null: false
    t.integer  "person_id",               null: false
    t.integer  "item_id",                 null: false
    t.integer  "score",       default: 1, null: false
    t.datetime "created_at",              null: false
  end

  add_index "votes", ["election_id", "person_id", "item_id"], name: "vote_ballot_idx"

end
