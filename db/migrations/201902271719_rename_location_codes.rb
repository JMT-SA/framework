Sequel.migration do
  up do
    alter_table(:locations) do
      rename_column :location_code, :location_long_code
      rename_column :legacy_barcode, :location_short_code
      add_column :print_code, String
      add_unique_constraint :location_short_code, name: :location_location_short_code_uniq
      set_column_allow_null :location_short_code, false
    end
  end

  down do
    alter_table(:locations) do
      drop_constraint :location_location_short_code_uniq
      drop_column :print_code
      rename_column :location_long_code, :location_code
      rename_column :location_short_code, :legacy_barcode
      set_column_allow_null :legacy_barcode, true
    end
  end
end
