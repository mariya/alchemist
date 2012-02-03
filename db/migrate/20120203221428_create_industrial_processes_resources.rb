class CreateIndustrialProcessesResources < ActiveRecord::Migration
  def change
    create_table :industrial_processes_resources, :id => false do |t|
      t.references :industrial_process, :null => false
      t.references :resource, :null => false
    end
  end
end
