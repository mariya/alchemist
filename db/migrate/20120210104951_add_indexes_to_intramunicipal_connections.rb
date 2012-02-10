class AddIndexesToIntramunicipalConnections < ActiveRecord::Migration
  def change
    add_index(:intramunicipal_connections, :municipality_name)
    add_index(:intramunicipal_connections, :resource_name)
    add_index(:intramunicipal_connections, :industrial_process_name)
    add_index(:intramunicipal_connections, :industry_category_name)
    add_index(:intramunicipal_connections, :input_nace_code)
    add_index(:intramunicipal_connections, :output_nace_code)
  end
end
