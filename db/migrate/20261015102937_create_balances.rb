class CreateBalances < ActiveRecord::Migration[8.1]
  def change
    create_table :balances do |t|
      # The unique composite index below already covers lookups by account_id.
      t.references :account, null: false, foreign_key: true, index: false
      t.date :recorded_on, null: false
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.timestamps
    end
    add_index :balances, [:account_id, :recorded_on], unique: true
  end
end
