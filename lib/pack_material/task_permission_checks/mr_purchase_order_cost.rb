# frozen_string_literal: true

module PackMaterialApp
  module TaskPermissionCheck
    class MrPurchaseOrderCost < BaseService
      attr_reader :task, :entity
      def initialize(task, cost_id = nil, purchase_order_id: nil)
        @task = task
        @repo = ReplenishRepo.new
        @id = cost_id
        @entity = @id ? @repo.find_mr_purchase_order_cost(cost_id) : nil
        @purchase_order_id = purchase_order_id
        @purchase_order = purchase_order
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
        return failed_response 'Approved Purchase Order can not be changed' if purchase_order_approved?

        all_ok
      end

      def update?
        return failed_response 'Record not found' unless @entity
        return failed_response 'Approved Purchase Order can not be changed' if purchase_order_approved?

        all_ok
      end

      def destroy?
        return failed_response 'Record not found' unless @entity
        return failed_response 'Approved Purchase Order can not be changed' if purchase_order_approved?

        all_ok
      end

      def purchase_order_approved?
        @purchase_order.approved
      end

      def purchase_order
        @repo.find_mr_purchase_order(@purchase_order_id || @entity.mr_purchase_order_id)
      end
    end
  end
end
