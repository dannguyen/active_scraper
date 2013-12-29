class CreateActiveScraperRequests < ActiveRecord::Migration
  def change
    create_table :active_scraper_requests do |t|
      t.string :host
      t.text :query
      t.string :path
      t.string :custom_tag

      t.timestamps
    end

    add_index :active_scraper_requests, [:host, :path]

  end
end
