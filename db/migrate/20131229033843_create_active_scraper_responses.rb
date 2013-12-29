class CreateActiveScraperResponses < ActiveRecord::Migration
  def change
    create_table :active_scraper_responses do |t|
      t.text :body, :limit => 4294967295
      t.integer :code
      t.text :headers
      t.string :content_type
      t.integer :checksum
      t.integer :active_scraper_request_id

      t.timestamps      
    end

    add_index :active_scraper_responses, [:active_scraper_request_id, :created_at]
    add_index :active_scraper_responses, [:active_scraper_request_id, :checksum]
  end
end
