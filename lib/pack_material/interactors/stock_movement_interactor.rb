# frozen_string_literal: true

module PackMaterialApp
  class StockMovementInteractor < BaseInteractor
    def create_stock_movement_report(params)
      res = validate_stock_movement_params(params)
      return validation_failed_response(res) if res.failure?

      repo.validate_stock_movement_report_date_params(res)
    end

    def periodic_stock_report_grid(params)
      {
        columnDefs: make_column_definitions,
        rowDefs: repo.stock_movement_report(params[:start_date], params[:end_date])
      }.to_json
    end

    def periodic_stock_report_records_grid(params)
      {
        columnDefs: records_column_definitions,
        rowDefs: repo.stock_movement_report_records(params[:start_date], params[:end_date])
      }.to_json
    end

    private

    def repo
      @repo ||= StockMovementReportRepo.new
    end

    def mr_inventory_transaction(id)
      repo.find_mr_inventory_transaction(id)
    end

    def validate_stock_movement_params(params)
      StockMovementSchema.call(params)
    end

    def validate_stock_movement_report_date_params(params)
      repo.def validate_stock_movement_report_date_params(params)
    end

    def make_column_definitions
      Crossbeams::DataGrid::ColumnDefiner.new.make_columns do |mk|
        mk.integer 'id', 'MRPV ID'
        mk.col 'product_variant_code', 'Product Variant Code', width: 300
        mk.numeric 'opening_balance', nil, width: 150
        mk.numeric 'quantity_received', nil, width: 150
        mk.numeric 'quantity_returned', nil, width: 150
        mk.numeric 'quantity_sold', nil, width: 150
        mk.numeric 'closing_balance', nil, width: 150
      end
    end

    def records_column_definitions
      Crossbeams::DataGrid::ColumnDefiner.new.make_columns do |mk|
        mk.integer 'id', nil, hide: true
        mk.integer 'mr_product_variant_id', 'MRPV ID', width: 130
        mk.integer 'applicable_id', nil, width: 130
        mk.numeric 'quantity', nil, width: 130
        mk.col 'type', nil, width: 130
        mk.col 'actioned_at', nil, width: 180
      end
    end
  end
end
