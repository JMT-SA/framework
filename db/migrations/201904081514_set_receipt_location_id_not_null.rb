Sequel.migration do
  up do
    alter_table(:mr_deliveries) do
      set_column_allow_null :receipt_location_id, false
    end
  end

  down do
    alter_table(:mr_deliveries) do
      set_column_allow_null :receipt_location_id, true
    end
  end
end
