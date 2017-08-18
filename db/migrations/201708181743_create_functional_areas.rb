require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:functional_areas, :ignore_index_errors=>true) do
      primary_key :id
      String :functional_area_name, :size=>255, :null=>false
      TrueClass :active, :default=>true
      DateTime :created_at, :null=>false
      DateTime :updated_at, :null=>false
      
      index [:functional_area_name], :name=>:functional_areas_unique_functional_area_name, :unique=>true
    end

    pgt_created_at(:functional_areas,
                   :created_at,
                   function_name: :functional_areas_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:functional_areas,
                   :updated_at,
                   function_name: :functional_areas_set_updated_at,
                   trigger_name: :set_updated_at)
  end

  down do
    drop_trigger(:functional_areas, :set_created_at)
    drop_function(:functional_areas_set_created_at)
    drop_trigger(:functional_areas, :set_updated_at)
    drop_function(:functional_areas_set_updated_at)
    drop_table :functional_areas
  end
end
