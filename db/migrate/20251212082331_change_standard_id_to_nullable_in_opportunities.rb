class ChangeStandardIdToNullableInOpportunities < ActiveRecord::Migration[7.1]
  def change
    change_column_null :opportunities, :standard_id, true
  end
end
