Sequel.migration do
  up do
    create_table(:security_groups_security_permissions, ignore_index_errors: true) do
      foreign_key :security_group_id, :security_groups, null: false, key: [:id]
      foreign_key :security_permission_id, :security_permissions, null: false, key: [:id]
      
      index [:security_group_id, :security_permission_id], name: :security_groups_security_permissions_idx, unique: true
    end
  end

  down do
    drop_table(:security_groups_security_permissions)
  end
end
