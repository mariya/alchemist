class CreateNaceCodesResources < ActiveRecord::Migration
  def change
    create_table :nace_codes_resources, :id => false do |t|
      t.references :nace_code, :null => false
      t.references :resource, :null => false
    end
  end
end
