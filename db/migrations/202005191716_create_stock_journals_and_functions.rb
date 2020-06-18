Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:stock_journal_entries, ignore_index_errors: true) do
      primary_key :id
      foreign_key :mr_product_variant_id, :material_resource_product_variants, null: false, key: [:id]

      BigDecimal :opening_balance, size: [17,5]
      DateTime :opening_balance_at # 1 Jan 2020 00:00:00

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:party_id], name: :fki_stock_journals_mr_product_variant_ids
    end

    pgt_created_at(:stock_journal_entries,
                   :created_at,
                   function_name: :stock_journal_entries_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:stock_journal_entries,
                   :updated_at,
                   function_name: :stock_journal_entries_set_updated_at,
                   trigger_name: :set_updated_at)

    root_dir = File.expand_path('..', __dir__)
    sql = File.read(File.join(root_dir, 'ddl', 'functions', 'fn_stock_quantity_bsa.sql'))
    run sql

    sql = File.read(File.join(root_dir, 'ddl', 'functions', 'fn_stock_quantity_received.sql'))
    run sql

    sql = File.read(File.join(root_dir, 'ddl', 'functions', 'fn_stock_quantity_returned.sql'))
    run sql

    sql = File.read(File.join(root_dir, 'ddl', 'functions', 'fn_stock_quantity_sold.sql'))
    run sql

    sql = File.read(File.join(root_dir, 'ddl', 'functions', 'fn_stock_total_at.sql'))
    run sql
  end

  down do
    run 'DROP FUNCTION public.fn_stock_quantity_bsa(integer, date, date);'
    run 'DROP FUNCTION public.fn_stock_quantity_received(integer, date, date);'
    run 'DROP FUNCTION public.fn_stock_quantity_returned(integer, date, date);'
    run 'DROP FUNCTION public.fn_stock_quantity_sold(integer, date, date);'
    run 'DROP FUNCTION public.fn_stock_total_at(integer, date, date);'

    drop_trigger(:stock_journal_entries, :set_created_at)
    drop_function(:stock_journal_entries_set_created_at)
    drop_trigger(:stock_journal_entries, :set_updated_at)
    drop_function(:stock_journal_entries_set_updated_at)
    drop_table(:stock_journal_entries)
  end
end
