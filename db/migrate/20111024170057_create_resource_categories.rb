class CreateResourceCategories < ActiveRecord::Migration
  def change
    create_table :resource_categories do |t|
      t.string :name
      t.string :ewc_name
      t.string :ancestry
      t.timestamps
    end
  end
end
