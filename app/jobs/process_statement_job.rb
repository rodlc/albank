class ProcessStatementJob < ApplicationJob
  queue_as :default

  def perform(statement_id, file_path)
    statement = Statement.find(statement_id)

    Rails.logger.info("[JOB] Processing statement ##{statement_id}")
    data = LlmProcessor.new.process(file_path)
    transactions = data[:transactions] || []

    if data[:error] || transactions.empty?
      Rails.logger.error("[JOB] LLM failed for statement ##{statement_id}: #{data[:error]}")
      statement.failed!
      return
    end

    # Créer les expenses
    transactions.each do |transaction|
      category = Category.find_by(name: transaction[:category])
      next unless category

      expense = Expense.create!(
        category: category,
        subtotal: transaction[:amount].to_f.abs,
        label: transaction[:label],
        statement: statement
      )

      # Auto-création des Opportunities si Standard disponible
      standard = Standard.where(category: category)
                         .valid_for_statement(statement.date)
                         .first
      if standard
        opp = Opportunity.create!(expense: expense, standard: standard, status: :pending)
        opp.classify!
      end
    end

    statement.update!(total: data[:total])
    statement.ready!
    Rails.logger.info("[JOB] Statement ##{statement_id} ready: #{statement.expenses.count} expenses")
  rescue StandardError => e
    Rails.logger.error("[JOB] Error processing statement ##{statement_id}: #{e.message}")
    statement&.failed!
  ensure
    # Cleanup temp file
    File.delete(file_path) if file_path && File.exist?(file_path)
  end
end
