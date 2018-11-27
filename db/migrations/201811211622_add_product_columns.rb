# require 'sequel_postgresql_triggers' # Uncomment this line for created_at and updated_at triggers.
Sequel.migration do
  up do
    run "INSERT INTO material_resource_product_columns (material_resource_domain_id, column_name, short_code, description)
      SELECT dom.id, sub.column_name, sub.short_code, sub.description
      FROM material_resource_domains dom
        JOIN (SELECT * FROM (VALUES
          ('analysis_code', 'ANCD', 'Analysis Code', 1),
          ('party', 'PART', 'Party', 1),
          ('season_year_use', 'YEAR', 'Season Year Use', 1))
          AS t(column_name, short_code, description, n)) sub ON sub.n = 1
      WHERE dom.domain_name = 'Pack Material';"

    alter_table(:pack_material_products) do
      add_column :analysis_code, String
      add_column :party, String
      add_column :season_year_use, String
    end

    alter_table(:pack_material_product_variants) do
      add_column :analysis_code, String
      add_column :party, String
      add_column :season_year_use, String
      add_column :specification_reference, String
    end
  end

  down do
    run "DELETE FROM material_resource_product_columns WHERE material_resource_product_columns.short_code in ('ANCD', 'PART', 'YEAR');"

    alter_table(:pack_material_products) do
      drop_column :analysis_code
      drop_column :party
      drop_column :season_year_use
    end

    alter_table(:pack_material_product_variants) do
      drop_column :analysis_code
      drop_column :party
      drop_column :season_year_use
      drop_column :specification_reference
    end
  end
end
