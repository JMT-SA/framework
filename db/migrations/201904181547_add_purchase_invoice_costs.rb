require 'sequel_postgresql_triggers' # Uncomment this line for created_at and updated_at triggers.
Sequel.migration do
  up do
    extension :pg_triggers

    alter_table(:mr_cost_types) do
      rename_column :cost_code_string, :cost_type_code
    end

    create_table(:mr_purchase_invoice_costs, ignore_index_errors: true) do
      primary_key :id
      foreign_key :mr_cost_type_id, :mr_cost_types, key: [:id]
      foreign_key :mr_delivery_id, :mr_deliveries, key: [:id]
      BigDecimal :amount, size: [7, 2]
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:mr_cost_type_id], name: :fki_mr_purchase_invoice_costs_mr_cost_types
      index [:mr_delivery_id], name: :fki_mr_purchase_invoice_costs_mr_deliveries
    end
    pgt_created_at(:mr_purchase_invoice_costs,
                   :created_at,
                   function_name: :mr_purchase_invoice_costs_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:mr_purchase_invoice_costs,
                   :updated_at,
                   function_name: :mr_purchase_invoice_costs_set_updated_at,
                   trigger_name: :set_updated_at)
    run "SELECT audit.audit_table('mr_purchase_invoice_costs', true, true,'{updated_at}'::text[]);"
  end

  down do
    drop_trigger(:mr_purchase_invoice_costs, :set_created_at)
    drop_function(:mr_purchase_invoice_costs_set_created_at)
    drop_trigger(:mr_purchase_invoice_costs, :set_updated_at)
    drop_function(:mr_purchase_invoice_costs_set_updated_at)
    drop_table(:mr_purchase_invoice_costs)

    alter_table(:mr_cost_types) do
      rename_column :cost_type_code, :cost_code_string
    end
  end
end
