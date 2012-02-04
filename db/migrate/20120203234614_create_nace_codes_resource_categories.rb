class CreateNaceCodesResourceCategories < ActiveRecord::Migration
  def change
    create_table :nace_codes_resource_categories, :id => false do |t|
      t.references :nace_code, :null => false
      t.references :resource_category, :null => false
    end
  end
end
