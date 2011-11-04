class CreateResources < ActiveRecord::Migration
  def change
    create_table :resources do |t|
      t.string :name, :null => false
      t.timestamps
    end

    create_table :resource_categories_resources, :id => false do |t|
      t.references :resource_category, :null => false
      t.references :resource, :null => false
    end
  end
end
