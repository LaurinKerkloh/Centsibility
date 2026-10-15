class AllowSeveralBalancesPerDate < ActiveRecord::Migration[8.1]
  def change
    remove_index :balances, [:account_id, :recorded_on], unique: true
    add_index :balances, [:account_id, :recorded_on]
  end
end
