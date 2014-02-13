class CreateActiveScraperCachedRequests < ActiveRecord::Migration
  def change
    create_table :active_scraper_cached_requests do |t|
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

  end
end
