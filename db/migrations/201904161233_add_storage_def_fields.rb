Sequel.migration do
  up do
    alter_table(:location_storage_definitions) do
      add_column :storage_definition_format, String
      add_column :storage_definition_description, String
    end
  end

  down do
    alter_table(:location_storage_definitions) do
      drop_column :storage_definition_format
      drop_column :storage_definition_description
    end
  end
end
