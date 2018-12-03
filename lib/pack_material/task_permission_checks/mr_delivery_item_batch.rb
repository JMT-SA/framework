# frozen_string_literal: true

module PackMaterialApp
  module TaskPermissionCheck
    class MrDeliveryItemBatch < BaseService
      attr_reader :task, :entity
      def initialize(task, delivery_item_batch_id = nil, delivery_id: nil)
        @task = task
        @repo = ReplenishRepo.new
        @id = delivery_item_batch_id
        @delivery_id = delivery_id
        @entity = @id ? @repo.find_mr_delivery_item_batch(delivery_item_batch_id) : nil
        @delivery_id ||= @entity&.delivery_id
        @delivery = delivery
      end

      def call
        case task
        when :create
          create?
        when :update
          update?
        when :delete
          destroy?
        else
          raise ArgumentError, "Task \"#{task}\" is unknown for #{self.class}"
        end
      end

      private

      def create?
        return failed_response 'Verified delivery can not be changed' if delivery_verified?
        all_ok
      end

      def update?
        return failed_response 'Record not found' unless @entity
        return failed_response 'Invalid Delivery' unless valid_delivery?
        return failed_response 'Verified delivery can not be changed' if delivery_verified?
        all_ok
      end

      def destroy?
        return failed_response 'Record not found' unless @entity
        return failed_response 'Invalid Delivery' unless valid_delivery?
        return failed_response 'Verified delivery can not be changed' if delivery_verified?
        all_ok
      end

      def valid_delivery?
        item_delivery_id = @repo.find_mr_delivery_item(@entity.mr_delivery_item_id).mr_delivery_id
        item_delivery_id == @delivery_id
      end

      def delivery_verified?
        @delivery.verified
      end

      def delivery
        @repo.find_mr_delivery(@delivery_id)
      end
    end
  end
end
