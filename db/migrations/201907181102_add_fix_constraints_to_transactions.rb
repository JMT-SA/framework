Sequel.migration do
  up do
    alter_table(:mr_inventory_transactions) do
      set_column_allow_null :mr_inventory_transaction_type_id, false
      set_column_allow_null :business_process_id, false
      drop_index [:ref_no, :mr_inventory_transaction_type_id], name: :mr_inventory_transactions_unique_ref_no
      add_index [:ref_no, :mr_inventory_transaction_type_id, :business_process_id], name: :mr_inventory_transactions_unique_ref_no_combination, unique: true
    end
  end

  down do
    alter_table(:mr_inventory_transactions) do
      set_column_allow_null :mr_inventory_transaction_type_id, true
      set_column_allow_null :business_process_id, true
      drop_index [:ref_no, :mr_inventory_transaction_type_id, :business_process_id], name: :mr_inventory_transactions_unique_ref_no_combination
      add_index [:ref_no, :mr_inventory_transaction_type_id], name: :mr_inventory_transactions_unique_ref_no, unique: true
    end
  end
end
