require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:security_groups, ignore_index_errors: true) do
      primary_key :id
      String :security_group_name, size: 255
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
      
      index [:security_group_name], name: :security_groups_security_group_name_key, unique: true
    end

    pgt_created_at(:security_groups,
                   :created_at,
                   function_name: :security_groups_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:security_groups,
                   :updated_at,
                   function_name: :security_groups_set_updated_at,
                   trigger_name: :set_updated_at)
  end

  down do
    drop_trigger(:security_groups, :set_created_at)
    drop_function(:security_groups_set_created_at)
    drop_trigger(:security_groups, :set_updated_at)
    drop_function(:security_groups_set_updated_at)
    drop_table(:security_groups)
  end
end
