Sequel.migration do
  up do
    create_table(:account_codes, ignore_index_errors: true) do
      primary_key :id

      Integer :account_code, null: false
      String :description, null: false

      index :account_code, name: :unique_account_codes, unique: true
    end
  end

  down do
    drop_table(:account_codes)
  end
end
