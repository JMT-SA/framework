Sequel.migration do
  up do
    create_table(:measurement_units, ignore_index_errors: true) do
      primary_key :id
      String :unit_of_measure, null: false

      unique [:unit_of_measure]
    end

    create_table(:measurement_units_for_matres_types, ignore_index_errors: true) do
      primary_key :id
      foreign_key :measurement_unit_id, :measurement_units, null: false, key: [:id]
      foreign_key :material_resource_type_id, :material_resource_types, null: false, key: [:id]

      unique [:measurement_unit_id, :material_resource_type_id]
      index [:measurement_unit_id], name: :fki_measurement_units_for_matres_types_measurement_units
      index [:material_resource_type_id], name: :fki_measurement_units_for_matres_types_matres_types
    end
  end

  down do
    drop_table(:measurement_units_for_matres_types)
    drop_table(:measurement_units)
  end
end
