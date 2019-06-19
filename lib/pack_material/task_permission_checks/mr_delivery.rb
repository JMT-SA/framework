# frozen_string_literal: true

module PackMaterialApp
  module TaskPermissionCheck
    class MrDelivery < BaseService
      attr_reader :task, :entity
      # @param [Symbol] task
      # @param [Integer] delivery_id
      # @param [Hash] opts ex: { sku_ids: 1, loc_id: 1 }
      def initialize(task, delivery_id = nil, opts = {})
        @task   = task
        @repo   = ReplenishRepo.new
        @id     = delivery_id
        @entity = @id ? @repo.find_mr_delivery(@id) : nil
        @opts   = opts
      end

      def call
        return failed_response 'Record not found' unless @entity || task == :create

        case task
        when :create
          create_check
        when :update, :delete
          mutable_check
        when :verify
          verify_check
        when :putaway
          putaway_check
        when :add_invoice
          add_invoice_check
        when :complete_invoice
          complete_invoice_check
        when :bsa_in_progress_check
          bsa_in_progress_check
        else
          raise ArgumentError, "Task \"#{task}\" is unknown for #{self.class}"
        end
      end

      private

      def create_check
        all_ok
      end

      def mutable_check
        return failed_response "Verified delivery can not be #{task}d" if verified?

        all_ok
      end

      def verify_check
        return failed_response('Delivery is already verified') if verified?
        return failed_response('Delivery has no items') if no_items?
        return failed_response('Delivery has incomplete items') if incomplete_items?
        return failed_response('Delivery has items without batches') if items_without_batches?
        return failed_response('Delivery batch quantities do not equate to item quantities where applicable') if item_quantities_ignored?

        all_ok
      end

      def putaway_check
        return failed_response('Delivery Putaway has already been completed') if putaway_completed?

        all_ok
      end

      def bsa_in_progress_check
        return failed_response('Bulk Stock Adjustment in progress') if bsa_in_progress?

        all_ok
      end

      def add_invoice_check
        return failed_response('Delivery has not been verified') unless verified?

        all_ok
      end

      def complete_invoice_check
        return failed_response('Delivery Purchase Invoice has already been completed') if invoice_completed?
        return failed_response('Delivery has items without prices') if items_without_prices?
        return failed_response('Purchase Invoice incomplete') if invoice_incomplete?

        all_ok
      end

      def putaway_completed?
        @entity.putaway_completed
      end

      def invoice_completed?
        @entity.invoice_completed
      end

      def invoice_incomplete?
        @entity.supplier_invoice_ref_number.nil? || @entity.supplier_invoice_date.nil?
      end

      def verified?
        @entity.verified
      end

      def no_items?
        @repo.mr_delivery_items(@id).empty?
      end

      def items_without_batches?
        @repo.items_without_batches(@id)
      end

      def items_without_prices?
        @repo.items_without_prices(@id)
      end

      def incomplete_items?
        @repo.incomplete_items(@id)
      end

      def item_quantities_ignored?
        !@repo.batch_quantities_match(@id)
      end

      def bsa_in_progress?
        bsa_repo = BulkStockAdjustmentRepo.new
        bsa_repo.any_in_progress?(@opts)
      end
    end
  end
end
