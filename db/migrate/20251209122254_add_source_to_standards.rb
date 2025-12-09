class AddSourceToStandards < ActiveRecord::Migration[7.1]
  def change
    add_column :standards, :source, :string
    add_column :standards, :source_url, :string
    add_column :standards, :scraped_at, :datetime
  end
end
