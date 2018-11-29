# require 'sequel_postgresql_triggers' # Uncomment this line for created_at and updated_at triggers.
Sequel.migration do
  up do
    run "INSERT INTO material_resource_product_columns (material_resource_domain_id, column_name, short_code, description)
      SELECT dom.id, sub.column_name, sub.short_code, sub.description
      FROM material_resource_domains dom
        JOIN (SELECT * FROM (VALUES
          ('reference_dimension_2', 'RFD2', 'Reference Dimension 2', 1))
          AS t(column_name, short_code, description, n)) sub ON sub.n = 1
      WHERE dom.domain_name = 'Pack Material';"

    alter_table(:pack_material_products) do
      add_column :reference_dimension_2, String
    end

    alter_table(:pack_material_product_variants) do
      add_column :reference_dimension_2, String
    end
  end

  down do
    run "DELETE FROM material_resource_product_columns WHERE material_resource_product_columns.short_code in ('RFD2');"

    alter_table(:pack_material_products) do
      drop_column :reference_dimension_2
    end

    alter_table(:pack_material_product_variants) do
      drop_column :reference_dimension_2
    end
  end
end
