Sequel.migration do
  up do
    alter_table(:mr_sku_locations) do
      set_column_default :quantity, 0
    end
  end

  down do
    # do nothing
  end
end
