class CreateOrgaUserRecipeTable < ActiveRecord::Migration[5.2]
  
  def change
    create_table :organizations do |t|
      t.string :name
    end
    add_index :organizations, :name, unique: true

    create_table :users do |t|
      t.belongs_to :organization, index: true
      t.string :email
      t.string :password
    end
    add_index :users, :email, unique: true

    create_table :recipes do |t|
      t.belongs_to :organization, index: true
      t.string :title, null: false, default: ""
      t.string :description, null: true, default: ""
      t.string :content, null: true, default: ""
      t.string :pictureList, array: true, default: []
    end
    add_index :recipes, :title, unique: true
  end
end
