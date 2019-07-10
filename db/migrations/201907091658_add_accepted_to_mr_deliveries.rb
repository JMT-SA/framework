Sequel.migration do
  up do
    run 'CREATE SEQUENCE doc_seqs_waybill_number;'
    alter_table(:mr_deliveries) do
      add_column :accepted_over_supply, TrueClass, default: false
      add_column :waybill_number, Integer, null: true
    end
  end

  down do
    alter_table(:mr_deliveries) do
      drop_column :accepted_over_supply
      drop_column :waybill_number
    end
    run 'DROP SEQUENCE doc_seqs_waybill_number;'
  end
end
