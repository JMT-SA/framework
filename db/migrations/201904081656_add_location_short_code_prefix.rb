Sequel.migration do
  up do
    alter_table(:location_storage_types) do
      add_column :location_short_code_prefix, String
    end

    unless ENV['RACK_ENV'] == 'test'
      run <<~SQL
        DROP TRIGGER check_for_reserved_data ON location_storage_types;
        
        UPDATE location_storage_types
        SET location_short_code_prefix = '01'
        WHERE storage_type_code = 'Pack Material';

        SELECT set_reserved_data_on_table('location_storage_types', 'storage_type_code', '{Pack Material}'::text[]);
      SQL
    end
  end

  down do
    alter_table(:location_storage_types) do
      drop_column :location_short_code_prefix
    end
  end
end
