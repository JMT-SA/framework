Sequel.migration do
  up do
    alter_table(:program_functions) do
      add_column :show_in_iframe, TrueClass, default: false
    end
  end

  down do
    alter_table(:program_functions) do
      drop_column :show_in_iframe
    end
  end
end
