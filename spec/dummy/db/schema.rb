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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20131229033843) do

  create_table "active_scraper_cached_requests", force: true do |t|
    t.string   "scheme"
    t.string   "host"
    t.text     "query"
    t.string   "path"
    t.string   "meta_tag"
    t.string   "extname"
    t.boolean  "is_obfuscated"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_fetched_at"

  end

  add_index "active_scraper_cached_requests", ["host", "path"], name: "index_as_requests_on_host_and_path"

  create_table "active_scraper_cached_responses", force: true do |t|
    t.text     "body",                      limit: 4294967295
    t.integer  "code"
    t.text     "headers"
    t.string   "content_type"
    t.integer  "checksum"
    t.integer  "cached_request_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_scraper_cached_responses", ["cached_request_id", "checksum"], name: "index_as_request_id_and_checksum"
  add_index "active_scraper_cached_responses", ["cached_request_id", "created_at"], name: "index_as_request_id_and_created_at"

end
