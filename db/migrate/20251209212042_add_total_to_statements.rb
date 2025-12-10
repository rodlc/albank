class AddTotalToStatements < ActiveRecord::Migration[7.1]
  def change
    add_column :statements, :total, :decimal, precision: 10, scale: 2
  end
end
