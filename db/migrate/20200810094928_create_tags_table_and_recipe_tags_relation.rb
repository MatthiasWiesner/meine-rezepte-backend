class CreateTagsTableAndRecipeTagsRelation < ActiveRecord::Migration[5.2]
  def change
    create_table :tags do |t|
      t.string :name
    end
    add_index :tags, :name, unique: true

    create_join_table :recipes, :tags do |t|
      t.index :recipe_id
      t.index :tag_id
    end
  end
end
