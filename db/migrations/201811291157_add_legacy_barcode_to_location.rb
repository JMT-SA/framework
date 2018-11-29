Sequel.migration do
  up do
    alter_table(:locations) do
      add_column :legacy_barcode, String
      add_index [:legacy_barcode], name: :locations_legacy_barcode, unique: true
    end
  end

  down do
    alter_table(:locations) do
      drop_column :legacy_barcode
      drop_index :legacy_barcode
    end
  end
end
