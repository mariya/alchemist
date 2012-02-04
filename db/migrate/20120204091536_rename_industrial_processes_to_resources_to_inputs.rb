class RenameIndustrialProcessesToResourcesToInputs < ActiveRecord::Migration
  def change
    add_column :industrial_processes_resources, :quantity, :float, :null => false, :default => 0
    rename_table :industrial_processes_resources, :inputs
  end
end
