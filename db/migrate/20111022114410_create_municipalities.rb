class CreateMunicipalities < ActiveRecord::Migration
  def change
    create_table :municipalities do |t|
      t.string :name, :null => false
      t.string :country, :length => 2, :null => false
      t.string :administrative_id
      t.float :latitude, :null => false
      t.float :longitude, :null => false
      t.timestamps
    end
  end
end
