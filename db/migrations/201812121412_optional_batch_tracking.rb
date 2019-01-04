require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    alter_table(:mr_skus) do
      add_foreign_key :mr_internal_batch_number_id, :mr_internal_batch_numbers, null: true, key: [:id]
      add_index [:mr_internal_batch_number_id], name: :fki_mr_skus_mr_internal_batch_numbers

      drop_column(:batch_number)
      drop_column(:initial_quantity)
    end

    alter_table(:mr_delivery_item_batches) do
      drop_column(:mr_internal_batch_number_id)
    end

    alter_table(:material_resource_product_variants) do
      add_column :use_fixed_batch_number, TrueClass, default: false
      add_foreign_key :mr_internal_batch_number_id, :mr_internal_batch_numbers, null: true, key: [:id]
    end
  end

  down do
    alter_table(:mr_skus) do
      drop_column(:mr_internal_batch_number_id)

      add_column(:batch_number, String)
      add_column(:initial_quantity, Numeric)
    end

    alter_table(:mr_delivery_item_batches) do
      add_column(:mr_internal_batch_number_id, Integer)
    end

    alter_table(:material_resource_product_variants) do
      drop_column(:use_fixed_batch_number)
      drop_column(:mr_internal_batch_number_id)
    end
  end
end
