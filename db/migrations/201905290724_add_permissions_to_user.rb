Sequel.migration do
  change do
    extension :pg_json
    add_column :users, :permission_tree, :jsonb
  end
end
