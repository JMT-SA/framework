Sequel.migration do
  up do
    alter_table(:vehicle_types) do
      set_column_allow_null :type_code, false
    end

    alter_table(:vehicles) do
      set_column_allow_null :vehicle_type_id, false
      set_column_allow_null :vehicle_code, false
    end
  end

  down do
    alter_table(:vehicle_types) do
      set_column_allow_null :type_code, true
    end

    alter_table(:vehicles) do
      set_column_allow_null :vehicle_type_id, false
      set_column_allow_null :vehicle_code, false
    end
  end
end
