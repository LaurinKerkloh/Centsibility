class CreateTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :transactions do |t|
      # The composite index below already covers lookups by account_id.
      t.references :account, null: false, foreign_key: true, index: false
      t.references :counterparty, foreign_key: true
      t.date :booked_on, null: false
      t.date :value_on, null: false
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.text :reference
      t.string :creditor_id
      t.string :mandate_reference
      t.string :customer_reference
      t.text :raw_row, null: false
      t.timestamps
    end
    add_index :transactions, [:account_id, :booked_on]
  end
end
