class CreateCounterparties < ActiveRecord::Migration[8.1]
  def change
    create_table :counterparties do |t|
      t.string :name, null: false
      t.string :iban
      t.timestamps
    end
    add_index :counterparties, :iban, unique: true, where: "iban IS NOT NULL"
    add_index :counterparties, :name, unique: true, where: "iban IS NULL"
  end
end
