Sequel.migration do
  up do
    unless ENV['RACK_ENV'] == 'test'
      run <<~SQL
        DROP TRIGGER check_for_reserved_data_del ON locations;
        DROP TRIGGER check_for_reserved_data_upd ON locations;        

        SELECT set_reserved_data_on_table('location_types', 'location_type_code', '{RECEIVING BAY}'::text[], '{location_type_code,can_be_moved}'::text[]);
      SQL
    end

    alter_table(:mr_deliveries) do
      add_foreign_key :receipt_location_id, :locations, key: [:id]
    end
  end

  down do
    unless ENV['RACK_ENV'] == 'test'
      run <<~SQL
        DROP TRIGGER check_for_reserved_data_del ON location_types;
        DROP TRIGGER check_for_reserved_data_upd ON location_types;

        SELECT set_reserved_data_on_table('locations', 'location_long_code', '{RECEIVING BAY}'::text[], '{location_long_code,active}'::text[]);
      SQL
    end

    alter_table(:mr_deliveries) do
      drop_column :receipt_location_id
    end
  end
end
