Sequel.migration do
  up do
    alter_table(:program_functions) do
      add_column :hide_if_const_true, String
      add_column :hide_if_const_false, String
    end
  end

  down do
    alter_table(:program_functions) do
      drop_column :hide_if_const_true
      drop_column :hide_if_const_false
    end
  end
end
