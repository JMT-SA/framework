Sequel.migration do
  up do
    alter_table(:printers) do
      add_column :server_ip, :inet
      add_column :printer_use, String
      add_column :active, :boolean, default: true

      add_index [:server_ip, :printer_code], name: :printers_ip_code, unique: true
    end

    alter_table(:printer_applications) do
      add_column :default_printer, :boolean, default: false
    end
  end

  down do
    alter_table(:printers) do
      drop_column :server_ip
      drop_column :printer_use
      drop_column :active
    end

    alter_table(:printer_applications) do
      drop_column :default_printer
    end
  end
end
