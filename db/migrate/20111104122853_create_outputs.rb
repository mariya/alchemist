class CreateOutputs < ActiveRecord::Migration
  def change
    create_table :outputs do |t|
      t.references :industry_category, :null => false
      t.references :resource_category, :null => false
      t.integer :tons_non_hazardous_waste_2008, :null => false
      t.timestamps
    end
  end
end
