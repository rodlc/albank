class CreateOpportunities < ActiveRecord::Migration[7.1]
  def change
    create_table :opportunities do |t|
      t.references :statement, null: false, foreign_key: true
      t.references :standard, null: false, foreign_key: true
      t.string :status, default: "pending"

      t.timestamps
    end
  end
end
