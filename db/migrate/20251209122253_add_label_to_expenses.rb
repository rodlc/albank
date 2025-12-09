class AddLabelToExpenses < ActiveRecord::Migration[7.1]
  def change
    add_column :expenses, :label, :string
  end
end
