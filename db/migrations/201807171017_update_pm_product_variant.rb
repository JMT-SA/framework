Sequel.migration do

  # Run update_product_menus.sql

  up do
    alter_table(:pack_material_product_variants) do
      drop_column(:standard)
      add_column(:product_variant_number, Integer)
      add_column(:active, TrueClass)
      add_column(:reference_dimension, String)
      add_column(:product_variant_code, String, null: false)
      drop_column(:length_mm)
      drop_column(:width_mm)
      drop_column(:height_mm)
      drop_column(:diameter_mm)
      drop_column(:thick_mm)
      drop_column(:thick_mic)
    end

    alter_table(:pack_material_products) do
      add_column(:active, TrueClass)
      add_column(:reference_dimension, String)
      drop_column(:length_mm)
      drop_column(:width_mm)
      drop_column(:height_mm)
      drop_column(:diameter_mm)
      drop_column(:thick_mm)
      drop_column(:thick_mic)
      drop_column(:specification_notes)
    end
  end

  down do
    alter_table(:pack_material_product_variants) do
      add_column(:standard, TrueClass)
      drop_column(:product_variant_number)
      drop_column(:active)
      drop_column(:reference_dimension)
      drop_column(:product_variant_code)
      add_column(:length_mm, Numeric)
      add_column(:width_mm, Numeric)
      add_column(:height_mm, Numeric)
      add_column(:diameter_mm, Numeric)
      add_column(:thick_mm, Numeric)
      add_column(:thick_mic, Numeric)
    end

    alter_table(:pack_material_products) do
      drop_column(:active)
      drop_column(:reference_dimension)
      add_column(:length_mm, Numeric)
      add_column(:width_mm, Numeric)
      add_column(:height_mm, Numeric)
      add_column(:diameter_mm, Numeric)
      add_column(:thick_mm, Numeric)
      add_column(:thick_mic, Numeric)
      add_column(:specification_notes, String)
    end
  end
end
