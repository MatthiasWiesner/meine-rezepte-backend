class ChangeRecipesTitleIndex < ActiveRecord::Migration[5.2]
  def change
    remove_index :recipes, name: :index_recipes_on_title
    add_index :recipes, [:title, :organization_id], unique: true
  end
end
