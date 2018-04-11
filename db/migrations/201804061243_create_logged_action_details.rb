Sequel.migration do
  up do
    create_table(Sequel[:audit][:logged_action_details], ignore_index_errors: true) do
      primary_key :id, type: :Bignum
      Bignum :transaction_id
      DateTime :action_tstamp_tx
      String :user_name
      String :context
      String :route_url
    end
    run 'ALTER TABLE audit.logged_action_details ALTER COLUMN transaction_id SET DEFAULT txid_current();'
    run 'ALTER TABLE audit.logged_action_details ALTER COLUMN action_tstamp_tx SET DEFAULT current_timestamp;'
  end

  down do
    drop_table(Sequel[:audit][:logged_action_details])
  end
end
