require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_array
    extension :pg_triggers

    create_table(:label_templates, ignore_index_errors: true) do
      primary_key :id
      String :label_template_name, null: false
      String :description, null: false
      String :application, null: false
      column :variables, 'text[]'
      TrueClass :active, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:label_template_name], name: :label_templates_unique_name, unique: true
    end

    pgt_created_at(:label_templates,
                   :created_at,
                   function_name: :label_templates_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:label_templates,
                   :updated_at,
                   function_name: :label_templates_set_updated_at,
                   trigger_name: :set_updated_at)

    # Log changes to this table. Exclude changes to the updated_at column.
    run "SELECT audit.audit_table('label_templates', true, true, '{updated_at}'::text[]);"
  end

  down do
    # Drop logging for this table.
    drop_trigger(:label_templates, :audit_trigger_row)
    drop_trigger(:label_templates, :audit_trigger_stm)

    drop_trigger(:label_templates, :set_created_at)
    drop_function(:label_templates_set_created_at)
    drop_trigger(:label_templates, :set_updated_at)
    drop_function(:label_templates_set_updated_at)
    drop_table(:label_templates)
  end
end
