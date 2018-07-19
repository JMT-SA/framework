Sequel.migration do

  # Run update_product_menus.sql

  up do
    alter_table(:pack_material_product_variants) do
      drop_column(:standard)
      add_column(:product_variant_number, Integer)
      add_column(:active, TrueClass)
    end

    alter_table(:pack_material_products) do
      add_column(:active, TrueClass)
      drop_column(:length_mm)
      drop_column(:width_mm)
      drop_column(:height_mm)
      drop_column(:diameter_mm)
      drop_column(:thick_mm)
      drop_column(:thick_mic)
    end
  end

  down do
    alter_table(:pack_material_product_variants) do
      add_column(:standard, TrueClass)
      drop_column(:product_variant_number)
      drop_column(:active)
    end

    alter_table(:pack_material_products) do
      drop_column(:active)
      add_column(:length_mm, Numeric)
      add_column(:width_mm, Numeric)
      add_column(:height_mm, Numeric)
      add_column(:diameter_mm, Numeric)
      add_column(:thick_mm, Numeric)
      add_column(:thick_mic, Numeric)
    end
  end
end
