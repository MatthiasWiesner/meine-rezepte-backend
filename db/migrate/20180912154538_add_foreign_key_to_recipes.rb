class AddForeignKeyToRecipes < ActiveRecord::Migration[5.2]
  def change
    add_column :recipes, :updated_by, :integer
  end
end
