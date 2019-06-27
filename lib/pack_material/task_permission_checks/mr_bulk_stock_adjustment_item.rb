# frozen_string_literal: true

module PackMaterialApp
  module TaskPermissionCheck
    class MrBulkStockAdjustmentItem < BaseService
      attr_reader :task, :entity
      def initialize(task, mr_bulk_stock_adjustment_item_id = nil)
        @task = task
        @repo = TransactionsRepo.new
        @id = mr_bulk_stock_adjustment_item_id
        @entity = @id ? @repo.find_mr_bulk_stock_adjustment_item(@id) : nil
        @bulk_stock_adjustment = @repo.find_mr_bulk_stock_adjustment(@entity.mr_bulk_stock_adjustment_id) if @entity
      end

      CHECKS = {
        create: :create_check,
        edit: :edit_check,
        delete: :delete_check
      }.freeze

      def call
        return failed_response 'Record not found' unless @entity || task == :create

        check = CHECKS[task]
        raise ArgumentError, "Task \"#{task}\" is unknown for #{self.class}" if check.nil?

        send(check)
      end

      private

      def create_check
        parent_fail_check
      end

      def edit_check
        parent_fail_check
      end

      def delete_check
        parent_fail_check
      end

      def parent_fail_check
        return failed_response 'Bulk Stock Adjustment has been completed' if parent_completed?
        return failed_response 'Bulk Stock Adjustment has been approved' if parent_approved?

        all_ok
      end

      def parent_completed?
        @bulk_stock_adjustment.completed
      end

      def parent_approved?
        @bulk_stock_adjustment.approved
      end
    end
  end
end
