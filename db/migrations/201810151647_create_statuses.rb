require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    create_table(Sequel[:audit][:current_statuses], ignore_index_errors: true) do
      primary_key :id, type: :Bignum
      Bignum :transaction_id
      DateTime :action_tstamp_tx
      String :table_name
      Integer :row_data_id
      String :status
      String :comment
      String :user_name

      index [:table_name, :row_data_id], unique: true
    end
    run 'ALTER TABLE audit.current_statuses ALTER COLUMN transaction_id SET DEFAULT txid_current();'
    run 'ALTER TABLE audit.current_statuses ALTER COLUMN action_tstamp_tx SET DEFAULT current_timestamp;'


    create_table(Sequel[:audit][:status_logs], ignore_index_errors: true) do
      primary_key :id, type: :Bignum
      Bignum :transaction_id
      DateTime :action_tstamp_tx
      String :table_name
      Integer :row_data_id
      String :status
      String :comment
      String :user_name

      index [:table_name, :row_data_id]
    end
    run 'ALTER TABLE audit.status_logs ALTER COLUMN transaction_id SET DEFAULT txid_current();'
    run 'ALTER TABLE audit.status_logs ALTER COLUMN action_tstamp_tx SET DEFAULT current_timestamp;'
  end

  down do
    drop_table(Sequel[:audit][:status_logs])
    drop_table(Sequel[:audit][:current_statuses])
  end
end
