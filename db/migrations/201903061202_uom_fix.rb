Sequel.migration do
  up do
    alter_table(:uoms) do
      rename_column :uoms_type_id, :uom_type_id
      drop_index :uom_code, name: :fki_uoms_codes_uom_types
      add_index [:uom_code, :uom_type_id], name: :fki_uom_codes_uom_types, unique: true
    end
  end

  down do
    alter_table(:uoms) do
      rename_column :uom_type_id, :uoms_type_id
      drop_index :uom_code, name: :fki_uom_codes_uom_types
      add_index [:uom_code, :uoms_type_id], name: :fki_uoms_codes_uom_types, unique: true
    end
  end
end
