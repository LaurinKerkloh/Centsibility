class CreateImports < ActiveRecord::Migration[8.1]
  def change
    create_table :imports do |t|
      t.references :account, null: false, foreign_key: true
      t.string :filename, null: false
      t.integer :skipped_count, null: false
      t.boolean :created_account, null: false, default: false
      t.timestamps
    end

    add_reference :transactions, :import, foreign_key: true
    add_reference :balances, :import, foreign_key: true
    # Counterparties outlive the import that created them once later imports use them too.
    add_reference :counterparties, :import, foreign_key: {on_delete: :nullify}
  end
end
