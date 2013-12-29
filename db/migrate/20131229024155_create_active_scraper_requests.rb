class CreateActiveScraperRequests < ActiveRecord::Migration
  def change
    create_table :active_scraper_requests do |t|
      t.string :host
      t.text :query
      t.string :path
      t.string :meta_tag
      t.boolean :is_obfuscated

      t.timestamps
    end

    add_index :active_scraper_requests, [:host, :path]

  end
end
