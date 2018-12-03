# frozen_string_literal: true

module PackMaterialApp
  module TaskPermissionCheck
    class MrDelivery < BaseService
      attr_reader :task, :entity
      def initialize(task, delivery_id = nil)
        @task = task
        @repo = ReplenishRepo.new
        @id = delivery_id
        @entity = @id ? @repo.find_mr_delivery(delivery_id) : nil
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
        return failed_response('Delivery has items without batches') if items_without_batches?
        return failed_response('Delivery batch quantities do not equate to item quantities') if item_quantities_ignored?
        all_ok
      end

      def verified?
        @entity.verified
      end

      def no_items?
        @repo.mr_delivery_items(@id).empty?
      end

      def items_without_batches?
        @repo.delivery_has_items_without_batches(@id).any?
      end

      def item_quantities_ignored?
        !@repo.delivery_items_fulfilled(@id)
      end
    end
  end
end
