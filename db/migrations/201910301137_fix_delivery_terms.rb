Sequel.migration do
  up do
    alter_table(:mr_delivery_terms) do
      add_column :description, String, text: true
      drop_column :is_consignment_stock
    end

    alter_table(:mr_purchase_orders) do
      drop_column :purchase_account_code
      add_column :is_consignment_stock, TrueClass, default: false
      add_foreign_key :account_code_id, :account_codes, null: true, key: [:id]
      add_index [:account_code_id], name: :fki_mr_purchase_orders_account_codes
    end
  end

  down do
    alter_table(:mr_delivery_terms) do
      drop_column :description
      add_column :is_consignment_stock, TrueClass, default: false
    end

    alter_table(:mr_purchase_orders) do
      add_column :purchase_account_code, String
      drop_index :account_code_id, name: :fki_mr_purchase_orders_account_codes
      drop_column :account_code_id
      drop_column :is_consignment_stock
    end
  end
end
