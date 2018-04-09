Sequel.migration do
  up do
    create_table(Sequel[:audit][:logged_action_details], ignore_index_errors: true) do
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

    run 'ALTER TABLE audit.logged_action_details ALTER COLUMN created_at SET DEFAULT now();'
  end

  down do
    drop_table(Sequel[:audit][:logged_action_details])
  end
end
