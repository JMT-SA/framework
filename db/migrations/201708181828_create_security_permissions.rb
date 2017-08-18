require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:security_permissions, ignore_index_errors: true) do
      primary_key :id
      String :security_permission, size: 255
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
      
      index [:security_permission], name: :security_permissions_security_permission_key, unique: true
    end

    pgt_created_at(:security_permissions,
                   :created_at,
                   function_name: :security_permissions_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:security_permissions,
                   :updated_at,
                   function_name: :security_permissions_set_updated_at,
                   trigger_name: :set_updated_at)
  end

  down do
    drop_trigger(:security_permissions, :set_created_at)
    drop_function(:security_permissions_set_created_at)
    drop_trigger(:security_permissions, :set_updated_at)
    drop_function(:security_permissions_set_updated_at)
    drop_table(:security_permissions)
  end
end
