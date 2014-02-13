class CreateActiveScraperCachedResponses < ActiveRecord::Migration
  def change
    create_table :active_scraper_cached_responses do |t|
      t.text     "body",                      limit: 4294967295
      t.integer  "code"
      t.text     "headers"
      t.string   "content_type"
      t.integer  "checksum"
      t.integer  "cached_request_id"
      t.timestamps      
    end

    add_index :active_scraper_cached_responses, [:cached_request_id, :created_at], name: 'index_request_id_and_created_at'
    add_index :active_scraper_cached_responses, [:cached_request_id, :checksum], name: 'index_request_id_and_checksum'
  end
end
