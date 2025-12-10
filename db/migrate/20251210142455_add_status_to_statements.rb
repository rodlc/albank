class AddStatusToStatements < ActiveRecord::Migration[7.1]
  def change
    add_column :statements, :status, :integer, default: 0, null: false
  end
end
