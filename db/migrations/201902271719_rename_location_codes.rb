Sequel.migration do
  up do
    alter_table(:locations) do
      drop_index :legacy_barcode, name: :locations_legacy_barcode
      rename_column :location_code, :location_long_code
      rename_column :legacy_barcode, :location_short_code
      add_column :print_code, String
      add_unique_constraint :location_short_code, name: :location_location_short_code_uniq
      set_column_allow_null :location_short_code, false
      add_index [:location_short_code], name: :locations_short_code_idx, unique: true
    end
  end

  down do
    alter_table(:locations) do
      drop_index :location_short_code, name: :locations_short_code_idx
      drop_constraint :location_location_short_code_uniq
      drop_column :print_code
      rename_column :location_long_code, :location_code
      rename_column :location_short_code, :legacy_barcode
      set_column_allow_null :legacy_barcode, true
      add_index [:legacy_barcode], name: :locations_legacy_barcode, unique: true
    end
  end
end
