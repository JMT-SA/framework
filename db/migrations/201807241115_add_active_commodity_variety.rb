Sequel.migration do
  up do
    alter_table(:material_resource_sub_types) do
      add_column(:active, TrueClass, default: true)
    end

    alter_table(:pack_material_product_variants) do
      set_column_default :active, true
      add_foreign_key :commodity_id, :commodities, null: true, key: [:id]
      add_foreign_key :marketing_variety_id, :marketing_varieties, null: true, key: [:id]

      add_index [:commodity_id], name: :fki_pack_material_product_variants_commodities
      add_index [:marketing_variety_id], name: :fki_pack_material_product_variants_marketing_variety_ids
    end
  end

  down do
    alter_table(:material_resource_sub_types) do
      drop_column(:active)
    end

    alter_table(:pack_material_product_variants) do
      set_column_default :active, false
      drop_column :commodity_id
      drop_column :marketing_variety_id
    end
  end
end
