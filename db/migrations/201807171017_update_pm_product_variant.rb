Sequel.migration do
  up do
    alter_table(:pack_material_product_variants) do
      drop_column(:standard)
      add_column(:product_variant_number, String)
      add_column(:active, TrueClass)
    end

    alter_table(:pack_material_products) do
      add_column(:active, TrueClass)
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
    end
  end
end
