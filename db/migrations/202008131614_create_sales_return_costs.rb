require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    create_table(:sales_return_costs) do
      primary_key :id
      foreign_key :mr_sales_return_id, :mr_sales_returns, null: false, key: [:id]
      foreign_key :mr_cost_type_id, :mr_cost_types, null: false, key: [:id]
      BigDecimal :amount, size: [17,5]
    end
  end

  down do
    drop_table(:sales_return_costs)
  end
end
