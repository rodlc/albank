class AddResultTypeToOpportunities < ActiveRecord::Migration[7.1]
  def change
    add_column :opportunities, :result_type, :string
  end
end
