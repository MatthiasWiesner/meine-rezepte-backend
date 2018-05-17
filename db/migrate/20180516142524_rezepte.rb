class Rezepte < ActiveRecord::Migration[5.2]
  def change
    create_table :recipes do |t|
      t.string :title, null: false, default: ""
      t.string :description, null: true, default: ""
      t.string :content, null: true, default: ""
      t.string :pictureList, array: true
    end
    add_index :recipes, :title, unique: true
  end
end
