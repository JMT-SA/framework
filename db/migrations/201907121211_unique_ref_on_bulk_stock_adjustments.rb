Sequel.migration do
  up do
    alter_table(:mr_bulk_stock_adjustments) do
      add_index [:ref_no], name: :unique_bulk_stock_adj_ref_no, unique: true
    end
  end

  down do
    alter_table(:mr_bulk_stock_adjustments) do
      drop_index :unique_bulk_stock_adj_ref_no
    end
  end
end
