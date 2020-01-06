Sequel.migration do
  up do
    extension :pg_json
    add_column :users, :profile, :jsonb
  end
  down do
    drop_column :users, :profile
  end
end
