class CreateIndustryCategoriesToNaceCodesTable < ActiveRecord::Migration
  def change
    create_table :industry_categories_nace_codes, :id => false do |t|
      t.references :industry_category, :null => false
      t.references :nace_code, :null => false
    end
  end
end
