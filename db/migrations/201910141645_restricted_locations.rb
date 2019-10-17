Sequel.migration do
  up do
    alter_table(:locations) do
      add_column :restricted, TrueClass, default: false
    end
  end

  down do
    alter_table(:locations) do
      drop_column :restricted
    end
  end
end
