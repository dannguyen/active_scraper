class CreateActiveScraperRequests < ActiveRecord::Migration
  def change
    create_table :active_scraper_requests do |t|
      t.string :host
      t.text :query
      t.string :path
      t.string :etag

      t.timestamps
    end
  end
end
