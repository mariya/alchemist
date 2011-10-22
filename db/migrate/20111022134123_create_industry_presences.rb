class CreateIndustryPresences < ActiveRecord::Migration
  def change
    create_table :industry_presences do |t|
      t.references :municipality, :null => false
      t.references :nace_code, :null => false
      t.integer :num_companies_with_employees, :null => false
      t.timestamps
    end
  end
end
