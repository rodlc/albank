class RenameOpportunitiesStatementIdToExpenseId < ActiveRecord::Migration[7.1]
  def change
    # Remove the incorrect FK pointing to expenses via statement_id
    remove_foreign_key :opportunities, column: :statement_id

    # Rename the column
    rename_column :opportunities, :statement_id, :expense_id

    # Add the correct FK pointing to expenses
    add_foreign_key :opportunities, :expenses
  end
end
