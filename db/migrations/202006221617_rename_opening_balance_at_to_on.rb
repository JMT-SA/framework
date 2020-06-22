Sequel.migration do
  up do
    alter_table(:stock_journal_entries) do
      set_column_type :opening_balance_at, Date
      rename_column :opening_balance_at, :opening_balance_on
    end
  end

  down do
    alter_table(:stock_journal_entries) do
      set_column_type :opening_balance_at, DateTime
      rename_column :opening_balance_on, :opening_balance_at
    end
  end
end
