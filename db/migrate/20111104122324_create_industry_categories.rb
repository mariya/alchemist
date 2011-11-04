class CreateIndustryCategories < ActiveRecord::Migration
  def change
    create_table :industry_categories do |t|
      t.string :name, :null => false
      t.timestamps
    end
  end
end
