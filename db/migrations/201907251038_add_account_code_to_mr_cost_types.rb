Sequel.migration do
  up do
    alter_table(:mr_cost_types) do
      add_column :account_code, String
    end

    run "UPDATE mr_cost_types SET account_code = 'FIXME';"

    alter_table(:mr_cost_types) do
      set_column_allow_null :account_code, false
      set_column_allow_null :cost_type_code, false
    end
  end

  down do
    alter_table(:mr_cost_types) do
      drop_column :account_code
      set_column_allow_null :cost_type_code, true
    end
  end
end
