class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts do |t|
      t.string :name, null: false
      t.string :iban, null: false, index: {unique: true}
      t.string :account_type
      t.timestamps
    end
  end
end
