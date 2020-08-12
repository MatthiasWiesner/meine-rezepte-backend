class UniqueRecipeTagsRelationEntries < ActiveRecord::Migration[5.2]
  def change
    add_index :recipes_tags, [:tag_id, :recipe_id], :unique => true
  end
end
