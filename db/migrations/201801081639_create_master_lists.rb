require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:master_lists, ignore_index_errors: true) do
      primary_key :id
      String :list_type, size: 255, null: false
      String :description, size: 255, null: false
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:list_type, :description], name: :master_lists_unique_typedesc, unique: true
    end

    pgt_created_at(:master_lists,
                   :created_at,
                   function_name: :master_lists_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:master_lists,
                   :updated_at,
                   function_name: :master_lists_set_updated_at,
                   trigger_name: :set_updated_at)
  end

  down do
    drop_trigger(:master_lists, :set_created_at)
    drop_function(:master_lists_set_created_at)
    drop_trigger(:master_lists, :set_updated_at)
    drop_function(:master_lists_set_updated_at)
    drop_table(:master_lists)
  end
end
