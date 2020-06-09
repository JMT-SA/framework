# frozen_string_literal: true

module PackMaterialApp
  class StockMovementInteractor < BaseInteractor
    def create_stock_movement_report(params)
      res = validate_stock_movement_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      repo.stock_movement_report(start_date, end_date)
      # repo.stock_movement_report(res.instance[:start_date], res.instance[:end_date])
      success_response('Created sales order cost', res)
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
  end
end
