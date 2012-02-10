class AddConnectionStatsToMunicipalities < ActiveRecord::Migration
  def change
    add_column :municipalities, :num_connections, :integer, :null => false, :default => 0
    add_column :municipalities, :mean_connections_factor, :float, :null => false, :default => 0
  end
end
