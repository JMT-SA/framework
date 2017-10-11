require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    # tm_group_types
    # tm_groups
    # tm
    # tm_tm_groups             [join]
    # tm_groups_tm_group_types [join]
    create_table(:target_market_group_types, ignore_index_errors: true) do
      primary_key :id
      String :target_market_group_type_code, size: 255, null:false
      TrueClass :active, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:target_market_group_type_code], name: :target_market_group_types_unique_code, unique: true
    end

    pgt_created_at(:target_market_group_types,
                   :created_at,
                   function_name: :target_market_group_types_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:target_market_group_types,
                   :updated_at,
                   function_name: :target_market_group_types_set_updated_at,
                   trigger_name: :set_updated_at)

    create_table(:target_market_groups, ignore_index_errors: true) do
      primary_key :id
      String :target_market_group_code, size: 255, null:false
      String :target_market_group_description, size: 255, null:false
      TrueClass :active, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:target_market_group_code], name: :target_market_groups_unique_code, unique: true
    end

    pgt_created_at(:target_market_groups,
                   :created_at,
                   function_name: :target_market_groups_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:target_market_groups,
                   :updated_at,
                   function_name: :target_market_groups_set_updated_at,
                   trigger_name: :set_updated_at)

    create_table(:target_markets, ignore_index_errors: true) do
      primary_key :id
      String :target_market_code, size: 255, null:false
      String :target_market_description, size: 255, null:false
      TrueClass :active, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:target_market_code], name: :target_markets_unique_code, unique: true
    end

    pgt_created_at(:target_markets,
                   :created_at,
                   function_name: :target_markets_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:target_markets,
                   :updated_at,
                   function_name: :target_markets_set_updated_at,
                   trigger_name: :set_updated_at)

    create_table(:target_markets_target_market_groups, ignore_index_errors: true) do
      foreign_key :target_market_id, :target_markets, null: false, key: [:id]
      foreign_key :target_market_group_id, :target_market_groups, null: false, key: [:id]
      
      index [:target_market_id], name: :fki_tm_tm_groups_target_market
      index [:target_market_group_id], name: :fki_tm_tm_groups_target_market_group
    end

    create_table(:target_market_groups_target_market_group_types, ignore_index_errors: true) do
      foreign_key :target_market_group_id, :target_market_groups, null: false, key: [:id]
      foreign_key :target_market_group_type_id, :target_market_group_types, null: false, key: [:id]
      
      index [:target_market_group_id], name: :fki_tm_tm_groups_target_market_group
      index [:target_market_group_type_id], name: :fki_tm_tm_groups_target_market_group_type
    end
  end

  down do
    drop_table(:target_market_groups_target_market_group_types)
    drop_table(:target_markets_target_market_groups)

    drop_trigger(:target_markets, :set_created_at)
    drop_function(:target_markets_set_created_at)
    drop_trigger(:target_markets, :set_updated_at)
    drop_function(:target_markets_set_updated_at)
    drop_table(:target_markets)

    drop_trigger(:target_market_groups, :set_created_at)
    drop_function(:target_market_groups_set_created_at)
    drop_trigger(:target_market_groups, :set_updated_at)
    drop_function(:target_market_groups_set_updated_at)
    drop_table(:target_market_groups)

    drop_trigger(:target_market_group_types, :set_created_at)
    drop_function(:target_market_group_types_set_created_at)
    drop_trigger(:target_market_group_types, :set_updated_at)
    drop_function(:target_market_group_types_set_updated_at)
    drop_table(:target_market_group_types)
  end
end
