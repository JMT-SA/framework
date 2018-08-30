require 'sequel_postgresql_triggers' # Uncomment this line for created_at and updated_at triggers.
Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:customer_types, ignore_index_errors: true) do
      primary_key :id
      String :type_code, null: false
      index [:type_code], name: :customer_types_unique_type_code, unique: true
    end

    create_table(:customers, ignore_index_errors: true) do
      primary_key :id
      foreign_key :party_role_id, :party_roles, null: false, key: [:id]
      foreign_key :customer_type_id, :customer_types, null: false, key: [:id]

      String :erp_customer_number

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:party_role_id], name: :fki_customers_party_roles
      index [:customer_type_id], name: :fki_customers_customer_types
    end
    pgt_created_at(:customers, :created_at, function_name: :customers_set_created_at, trigger_name: :set_created_at)
    pgt_updated_at(:customers, :updated_at, function_name: :customers_set_updated_at, trigger_name: :set_updated_at)

    create_table(:supplier_types, ignore_index_errors: true) do
      primary_key :id
      String :type_code, null: false
      index [:type_code], name: :supplier_types_unique_type_code, unique: true
    end

    create_table(:suppliers, ignore_index_errors: true) do
      primary_key :id
      foreign_key :party_role_id, :party_roles, null: false, key: [:id]
      foreign_key :supplier_type_id, :supplier_types, null: false, key: [:id]

      String :erp_supplier_number

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:party_role_id], name: :fki_suppliers_party_roles
      index [:supplier_type_id], name: :fki_suppliers_supplier_types
    end
    pgt_created_at(:suppliers, :created_at, function_name: :suppliers_set_created_at, trigger_name: :set_created_at)
    pgt_updated_at(:suppliers, :updated_at, function_name: :suppliers_set_updated_at, trigger_name: :set_updated_at)
  end

  down do
    drop_trigger(:suppliers, :set_created_at)
    drop_function(:suppliers_set_created_at)
    drop_trigger(:suppliers, :set_updated_at)
    drop_function(:suppliers_set_updated_at)
    drop_table(:suppliers)
    drop_table(:supplier_types)

    drop_trigger(:customers, :set_created_at)
    drop_function(:customers_set_created_at)
    drop_trigger(:customers, :set_updated_at)
    drop_function(:customers_set_updated_at)
    drop_table(:customers)
    drop_table(:customer_types)
  end
end
