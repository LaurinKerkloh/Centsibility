class AddRawRowIndexToTransactions < ActiveRecord::Migration[8.1]
  def change
    add_index :transactions, [:account_id, :raw_row]
  end
end
