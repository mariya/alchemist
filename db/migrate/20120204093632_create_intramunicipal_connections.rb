class CreateIntramunicipalConnections < ActiveRecord::Migration
  def change
    create_table :intramunicipal_connections do |t|
      t.string :municipality_name, :null => false
      t.string :resource_name, :null => false
      t.string :industrial_process_name, :null => false
      t.string :industry_category_name, :null => false
      t.integer :input_nace_code, :null => false
      t.integer :output_nace_code, :null => false
      t.float :factor, :null => false
      t.timestamps
    end
  end
end
