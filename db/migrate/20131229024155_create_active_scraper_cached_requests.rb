class CreateActiveScraperCachedResponses < ActiveRecord::Migration
  def change
    create_table :active_scraper_cached_responses do |t|
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
end
