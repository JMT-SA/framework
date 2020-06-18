Sequel.migration do
  up do
    alter_table(:mr_bulk_stock_adjustments) do
      add_column :completed_by, String
      add_column :completed_at, DateTime

      add_column :approved_by, String
      add_column :approved_at, DateTime

      add_column :signed_off_by, String
      add_column :signed_off_at, DateTime

      add_column :integrated_by, String
    end

    root_dir = File.expand_path('..', __dir__)
    sql = File.read(File.join(root_dir, 'ddl', 'functions', 'fn_get_latest_timestamp_for_status.sql'))
    run sql

    sql = File.read(File.join(root_dir, 'ddl', 'functions', 'fn_get_latest_user_for_status.sql'))
    run sql

    run <<~SQL
      UPDATE mr_bulk_stock_adjustments
      SET approved_by = (SELECT fn_get_latest_user_for_status('mr_bulk_stock_adjustments', 'APPROVED', mr_bulk_stock_adjustments.id)),
          approved_at = (SELECT fn_get_latest_timestamp_for_status('mr_bulk_stock_adjustments', 'APPROVED', mr_bulk_stock_adjustments.id)),
          completed_by = (SELECT fn_get_latest_user_for_status('mr_bulk_stock_adjustments', 'COMPLETED', mr_bulk_stock_adjustments.id)),
          completed_at = (SELECT fn_get_latest_timestamp_for_status('mr_bulk_stock_adjustments', 'COMPLETED', mr_bulk_stock_adjustments.id)),
          signed_off_by = (SELECT fn_get_latest_user_for_status('mr_bulk_stock_adjustments', 'SIGNED OFF', mr_bulk_stock_adjustments.id)),
          signed_off_at = (SELECT fn_get_latest_timestamp_for_status('mr_bulk_stock_adjustments', 'SIGNED OFF', mr_bulk_stock_adjustments.id)),
          integrated_by = (SELECT fn_get_latest_user_for_status('mr_bulk_stock_adjustments', 'BSA INTEGRATED', mr_bulk_stock_adjustments.id));
    SQL
  end

  down do
    run 'DROP FUNCTION public.fn_get_latest_timestamp_for_status(text, text, integer);'
    run 'DROP FUNCTION public.fn_get_latest_user_for_status(text, text, integer);'

    alter_table(:mr_bulk_stock_adjustments) do
      drop_column :completed_by
      drop_column :completed_at

      drop_column :approved_by
      drop_column :approved_at

      drop_column :signed_off_by
      drop_column :signed_off_at

      drop_column :integrated_by
    end
  end
end
