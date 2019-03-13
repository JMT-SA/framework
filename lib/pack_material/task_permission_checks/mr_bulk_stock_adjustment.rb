# frozen_string_literal: true

module PackMaterialApp
  module TaskPermissionCheck
    class MrBulkStockAdjustment < BaseService
      attr_reader :task, :entity
      def initialize(task, mr_bulk_stock_adjustment_id = nil)
        @task = task
        @repo = TransactionsRepo.new
        @id = mr_bulk_stock_adjustment_id
        @entity = @id ? @repo.find_mr_bulk_stock_adjustment(@id) : nil
      end

      CHECKS = {
        create: :create_check,
        edit: :edit_check,
        adjust_stock: :edit_header_check,
        edit_header: :edit_header_check,
        delete: :delete_check,
        complete: :complete_check,
        approve: :approve_check,
        reopen: :reopen_check
      }.freeze

      def call
        return failed_response 'Record not found' unless @entity || task == :create

        check = CHECKS[task]
        raise ArgumentError, "Task \"#{task}\" is unknown for #{self.class}" if check.nil?

        send(check)
      end

      private

      def create_check
        all_ok
      end

      def edit_header_check
        return failed_response 'Bulk Stock Adjustment has already been approved' if approved?
        return failed_response 'Bulk Stock Adjustment has been completed' if completed?
        all_ok
      end

      def edit_check
        all_ok
      end

      def delete_check
        return failed_response 'Bulk Stock Adjustment has already been approved' if approved?
        return failed_response 'Bulk Stock Adjustment has been completed, reopen to delete.' if completed?
        all_ok
      end

      def complete_check
        return failed_response 'Bulk Stock Adjustment has no items' if no_items?
        return failed_response 'Bulk Stock Adjustment has items where the actual quantity has not been set.' if incomplete_items?
        return failed_response 'Bulk Stock Adjustment has already been completed' if completed?
        all_ok
      end

      def approve_check
        return failed_response 'Bulk Stock Adjustment has not been completed yet' unless completed?
        return failed_response 'Bulk Stock Adjustment has already been approved' if approved?
        all_ok
      end

      def reopen_check
        return failed_response 'Bulk Stock Adjustment has not been completed' unless completed?
        return failed_response 'Bulk Stock Adjustment has already been approved' if approved?
        all_ok
      end

      def completed?
        @entity.completed
      end

      def approved?
        @entity.approved
      end

      def no_items?
        @repo.for_select_mr_bulk_stock_adjustment_items(where: { mr_bulk_stock_adjustment_id: @id }).none?
      end

      def incomplete_items?
        @repo.for_select_mr_bulk_stock_adjustment_items(where: { mr_bulk_stock_adjustment_id: @id, actual_quantity: nil }).any?
      end
    end
  end
end
