# require 'sequel_postgresql_triggers' # Uncomment this line for created_at and updated_at triggers.
Sequel.migration do
  change do
    extension :pg_json
    add_column :label_templates, :variable_rules, :jsonb
  end
end
