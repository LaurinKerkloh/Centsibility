class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.references :parent, foreign_key: {to_table: :categories}
      t.string :color
      t.timestamps
    end

    add_index :categories, "parent_id, lower(name)", unique: true, name: "index_categories_on_parent_id_and_lower_name"
    # SQLite treats NULLs as distinct, so main categories need their own partial index.
    add_index :categories, "lower(name)", unique: true, where: "parent_id IS NULL",
      name: "index_categories_on_lower_name_for_main"
  end
end
