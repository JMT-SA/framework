Sequel.migration do
  up do
    extension :pg_json
    add_column :users, :permission_tree, :jsonb
  end
  down do
    drop_column :users, :permission_tree
  end
end
