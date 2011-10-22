class CreateNaceCodesAndIndustrialProcesses < ActiveRecord::Migration
  def change
    create_table :nace_codes do |t|
      t.timestamps
    end

    create_table :industrial_processes do |t|
      t.string :name, :null => false
      t.timestamps
    end

    create_table :industrial_processes_nace_codes, :id => false do |t|
      t.references :industrial_process, :null => false
      t.references :nace_code, :null => false
    end
  end
end
