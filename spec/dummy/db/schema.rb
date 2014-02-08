# encoding: UTF-8
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
