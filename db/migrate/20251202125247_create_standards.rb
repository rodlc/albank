class CreateStandards < ActiveRecord::Migration[7.1]
  def change
    create_table :standards do |t|
      t.references :category, null: false, foreign_key: true
      t.decimal :average_amount, precision: 10, scale: 2
      t.decimal :min_amount, precision: 10, scale: 2
      t.decimal :max_amount, precision: 10, scale: 2
      t.string :unit
      t.date :date
      t.string :tiering

      t.timestamps
    end
  end
end
