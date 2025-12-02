class RenameStatementsToExpenses < ActiveRecord::Migration[7.1]
  def change
    # Create new statements table (will hold the document/PDF metadata)
    create_table :new_statements do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date, null: false

      t.timestamps
    end

    # Rename old statements to expenses
    rename_table :statements, :expenses

    # Rename amount to subtotal in expenses
    rename_column :expenses, :amount, :subtotal

    # Add statement_id to expenses (will replace user_id)
    add_reference :expenses, :statement, foreign_key: { to_table: :new_statements }

    # We'll need to migrate data: create a statement for each user/date combination
    # and update expenses accordingly
    reversible do |dir|
      dir.up do
        # Group expenses by user_id and date, create statements
        execute <<-SQL
          INSERT INTO new_statements (user_id, date, created_at, updated_at)
          SELECT DISTINCT user_id, date, NOW(), NOW()
          FROM expenses
          WHERE date IS NOT NULL
          ORDER BY user_id, date;
        SQL

        # Update expenses with the corresponding statement_id
        execute <<-SQL
          UPDATE expenses e
          SET statement_id = (
            SELECT id FROM new_statements s
            WHERE s.user_id = e.user_id AND s.date = e.date
            LIMIT 1
          );
        SQL
      end
    end

    # Make statement_id non-nullable after data migration
    change_column_null :expenses, :statement_id, false

    # Remove user_id and date from expenses (now stored in statements)
    remove_reference :expenses, :user, foreign_key: true
    remove_column :expenses, :date, :date

    # Rename new_statements to statements
    rename_table :new_statements, :statements
  end
end
