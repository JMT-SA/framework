Sequel.migration do
  up do
    alter_table(:mr_purchase_orders) do
      add_column :remarks, String, text: true
    end
  end

  down do
    alter_table(:mr_purchase_orders) do
      drop_column :remarks
    end
  end
end
