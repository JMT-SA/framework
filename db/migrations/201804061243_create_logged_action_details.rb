require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:logged_action_details, ignore_index_errors: true) do # THIS SHOULD ACTUALLY BE IN audit schema...
      primary_key :id, type: :Bignum
      String :schema_name, null: false
      String :table_name, null: false
      Integer :row_data_id
      String :action, null: false
      String :user_name
      String :context
      String :status
      DateTime :created_at, null: false

      check(action: %w[I D U T])

      index [:table_name, :row_data_id], name: :logged_action_details_table_id
    end

    pgt_created_at(:logged_action_details,
                   :created_at,
                   function_name: :logged_action_details_set_created_at,
                   trigger_name: :set_created_at)
  end

  down do
    drop_trigger(:logged_action_details, :set_created_at)
    drop_function(:logged_action_details_set_created_at)
    drop_table(:logged_action_details)
  end
end
