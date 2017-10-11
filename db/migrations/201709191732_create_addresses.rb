require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:address_types, ignore_index_errors: true) do
      primary_key :id
      String :address_type, size: 255, null:false
      TrueClass :active, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:address_type], name: :addresses_types_unique_code, unique: true
    end

    pgt_created_at(:address_types,
                   :created_at,
                   function_name: :address_types_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:address_types,
                   :updated_at,
                   function_name: :address_types_set_updated_at,
                   trigger_name: :set_updated_at)

    create_table(:addresses, ignore_index_errors: true) do
      primary_key :id
      foreign_key :address_type_id, :address_types, type: :integer, null: false
      String :address_line_1, size: 255, null:false
      String :address_line_2, size: 255
      String :address_line_3, size: 255
      String :city, size: 255
      String :postal_code, size: 255
      String :country, size: 255
      TrueClass :active, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:address_type_id], name: :fki_addresses_address_type_id
    end

    pgt_created_at(:addresses,
                   :created_at,
                   function_name: :addresses_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:addresses,
                   :updated_at,
                   function_name: :addresses_set_updated_at,
                   trigger_name: :set_updated_at)

    create_table(:party_addresses, ignore_index_errors: true) do
      primary_key :id
      foreign_key :address_id, :addresses, type: :integer, null: false
      foreign_key :party_id, :parties, type: :integer, null: false
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:address_id], name: :fki_party_addresses_address_id
      index [:party_id], name: :fki_party_addresses_party_id
    end

    pgt_created_at(:party_addresses,
                   :created_at,
                   function_name: :party_addresses_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:party_addresses,
                   :updated_at,
                   function_name: :party_addresses_set_updated_at,
                   trigger_name: :set_updated_at)
  end

  down do
    drop_trigger(:party_addresses, :set_created_at)
    drop_function(:party_addresses_set_created_at)
    drop_trigger(:party_addresses, :set_updated_at)
    drop_function(:party_addresses_set_updated_at)
    drop_table(:party_addresses)

    drop_trigger(:addresses, :set_created_at)
    drop_function(:addresses_set_created_at)
    drop_trigger(:addresses, :set_updated_at)
    drop_function(:addresses_set_updated_at)
    drop_table(:addresses)

    drop_trigger(:address_types, :set_created_at)
    drop_function(:address_types_set_created_at)
    drop_trigger(:address_types, :set_updated_at)
    drop_function(:address_types_set_updated_at)
    drop_table(:address_types)
  end
end
