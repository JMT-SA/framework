require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:user_email_groups, ignore_index_errors: true) do
      primary_key :id
      String :mail_group, size: 255, null: false
      TrueClass :active, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:mail_group], name: :user_email_groups_unique_code, unique: true
    end

    pgt_created_at(:user_email_groups,
                   :created_at,
                   function_name: :user_email_groups_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:user_email_groups,
                   :updated_at,
                   function_name: :user_email_groups_set_updated_at,
                   trigger_name: :set_updated_at)

    # JOIN user_email_groups to users
    # -------------------------------
    create_table(:user_email_groups_users, ignore_index_errors: true) do
      foreign_key :user_id, :users, null: false, key: [:id]
      foreign_key :user_email_group_id, :user_email_groups, null: false, key: [:id]
      
      index [:user_email_group_id, :user_id], name: :fki_user_email_groups_user, unique: true
    end
  end

  down do
    drop_table(:user_email_groups_users)
    
    drop_trigger(:user_email_groups, :set_created_at)
    drop_function(:user_email_groups_set_created_at)
    drop_trigger(:user_email_groups, :set_updated_at)
    drop_function(:user_email_groups_set_updated_at)
    drop_table(:user_email_groups)
  end
end
