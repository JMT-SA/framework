# frozen_string_literal: true

module PackMaterialApp
  module TaskPermissionCheck
    class MrInventoryTransaction < BaseService
      attr_reader :task
      # @param [symbol] task
      # @param [Hash] opts ex: { sku_id: 1, loc_id: 1 }
      def initialize(task, opts = {})
        @task = task
        @repo = ReplenishRepo.new
        @opts = opts
      end

      def call
        case task
        when :add
          add_check
        when :move
          move_check
        when :remove
          remove_check
        when :bsa_in_progress_check
          bsa_in_progress_check
        else
          raise ArgumentError, "Task \"#{task}\" is unknown for #{self.class}"
        end
      end

      private

      def add_check
        bsa_in_progress_check
      end

      def move_check
        bsa_in_progress_check
      end

      def remove_check
        bsa_in_progress_check
      end

      def bsa_in_progress_check
        return failed_response('Bulk Stock Adjustment in progress') if bsa_in_progress?

        all_ok
      end

      def bsa_in_progress?
        bsa_repo = BulkStockAdjustmentRepo.new
        bsa_repo.any_in_progress?(@opts)
      end
    end
  end
end
