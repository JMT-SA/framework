Sequel.migration do
  up do
    unless ENV['RACK_ENV'] == 'test'
      run <<~SQL
        SELECT set_reserved_data_on_table('locations', 'location_long_code', '{RECEIVING BAY}'::text[], '{location_long_code,active}'::text[]);
        SELECT set_reserved_data_on_table('organizations', 'short_description', '{#{ENV['IMPLEMENTATION_OWNER']}}'::text[], '{short_description}'::text[]);
        SELECT set_reserved_data_on_table('location_storage_types', 'storage_type_code', '{Pack Material}'::text[]);
        SELECT set_reserved_data_on_table('material_resource_domains', 'domain_name', '{Pack Material}'::text[]);
        SELECT set_reserved_data_on_table('business_processes', 'process', '{BULK STOCK ADJUSTMENT,STOCK TAKE,STOCK TAKE ON,DELIVERIES,VEHICLE JOBS,ADHOC TRANSACTIONS}'::text[]);
      SQL
    end
  end

  down do
    unless ENV['RACK_ENV'] == 'test'
      run <<~SQL
        DROP TRIGGER check_for_reserved_data_del ON locations;
        DROP TRIGGER check_for_reserved_data_upd ON locations;
        DROP TRIGGER check_for_reserved_data_del ON organizations;
        DROP TRIGGER check_for_reserved_data_upd ON organizations;
        DROP TRIGGER check_for_reserved_data ON location_storage_types;
        DROP TRIGGER check_for_reserved_data ON material_resource_domains;
        DROP TRIGGER check_for_reserved_data ON business_processes;
      SQL
    end
  end
end
