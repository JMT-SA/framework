# frozen_string_literal: true

module PackMaterialApp
  module TaskPermissionCheck
    class MrBulkStockAdjustmentPrice < BaseService
      attr_reader :task, :entity
      def initialize(task, mr_bulk_stock_adjustment_price_id = nil)
        @task = task
        @repo = TransactionsRepo.new
        @id = mr_bulk_stock_adjustment_price_id
        @entity = @id ? @repo.find_mr_bulk_stock_adjustment_price(@id) : nil
        @bulk_stock_adjustment = @repo.find_mr_bulk_stock_adjustment(@entity.mr_bulk_stock_adjustment_id) if @entity
      end

      CHECKS = {
        update_prices: :update_prices_check
      }.freeze

      def call
        return failed_response 'Record not found' unless @entity || task == :create

        check = CHECKS[task]
        raise ArgumentError, "Task \"#{task}\" is unknown for #{self.class}" if check.nil?

        send(check)
      end

      private

      def update_prices_check
        return failed_response 'Bulk Stock Adjustment has been approved' if parent_signed_off?

        all_ok
      end

      def parent_signed_off?
        @bulk_stock_adjustment.signed_off
      end
    end
  end
end
