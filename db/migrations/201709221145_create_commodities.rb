require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:commodity_groups, ignore_index_errors: true) do
      primary_key :id
      String :code, size: 255, null: false
      String :description, size: 255, null: false
      TrueClass :active, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:code], name: :commodity_groups_unique_code, unique: true
    end

    create_table(:commodities, ignore_index_errors: true) do
      primary_key :id
      foreign_key :commodity_group_id, :commodity_groups, type: :integer, null: false
      String :code, size: 255, null: false
      String :description, size: 255, null: false
      String :hs_code, size: 255, null: false
      TrueClass :active, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:code], name: :commodities_unique_code, unique: true
    end

    pgt_created_at(:commodity_groups,
                   :created_at,
                   function_name: :commodity_groups_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:commodity_groups,
                   :updated_at,
                   function_name: :commodity_groups_set_updated_at,
                   trigger_name: :set_updated_at)

    pgt_created_at(:commodities,
                   :created_at,
                   function_name: :commodities_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:commodities,
                   :updated_at,
                   function_name: :commodities_set_updated_at,
                   trigger_name: :set_updated_at)
  end

  down do
    drop_trigger(:commodities, :set_created_at)
    drop_function(:commodities_set_created_at)
    drop_trigger(:commodities, :set_updated_at)
    drop_function(:commodities_set_updated_at)
    drop_table(:commodities)

    drop_trigger(:commodity_groups, :set_created_at)
    drop_function(:commodity_groups_set_created_at)
    drop_trigger(:commodity_groups, :set_updated_at)
    drop_function(:commodity_groups_set_updated_at)
    drop_table(:commodity_groups)
  end
end
