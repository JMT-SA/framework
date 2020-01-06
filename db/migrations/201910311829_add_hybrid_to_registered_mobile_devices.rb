Sequel.migration do
  up do
    alter_table(:registered_mobile_devices) do
      add_column :hybrid_device, TrueClass, default: false
    end
  end

  down do
    alter_table(:registered_mobile_devices) do
      drop_column :hybrid_device
    end
  end
end
