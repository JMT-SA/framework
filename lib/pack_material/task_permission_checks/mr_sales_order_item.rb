# frozen_string_literal: true

module PackMaterialApp
  module TaskPermissionCheck
    class MrSalesOrderItem < BaseService
      attr_reader :task, :entity
      def initialize(task, sales_order_item_id = nil, sales_order_id: nil)
        @task = task
        @repo = SalesRepo.new
        @id = sales_order_item_id
        @entity = @id ? @repo.find_mr_sales_order_item(@id) : nil
        @sales_order_id = sales_order_id
        @sales_order = sales_order
      end

      CHECKS = {
        create: :create_check,
        edit: :edit_check,
        delete: :delete_check
      }.freeze

      def call
        return failed_response 'Sales Order Item record not found' unless @entity || task == :create

        check = CHECKS[task]
        raise ArgumentError, "Task \"#{task}\" is unknown for #{self.class}" if check.nil?

        send(check)
      end

      private

      def create_check
        return failed_response 'Sales Order has already been shipped' if sales_order_shipped?

        all_ok
      end

      def edit_check
        return failed_response 'Sales Order has already been shipped' if sales_order_shipped?

        all_ok
      end

      def delete_check
        return failed_response 'Sales Order has already been shipped' if sales_order_shipped?

        all_ok
      end

      def sales_order_shipped?
        @sales_order.shipped
      end

      def sales_order
        @repo.find_mr_sales_order(@sales_order_id || @entity.mr_sales_order_id)
      end
    end
  end
end
