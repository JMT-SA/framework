# frozen_string_literal: true

module PackMaterialApp
  module TaskPermissionCheck
    class MrSalesOrder < BaseService
      attr_reader :task, :entity
      def initialize(task, mr_sales_order_id = nil, current_user: nil)
        @task = task
        @repo = SalesRepo.new
        @id = mr_sales_order_id
        @entity = @id ? @repo.find_mr_sales_order(@id) : nil
        @user = current_user
      end

      CHECKS = {
        create: :create_check,
        edit: :edit_check,
        can_ship: :ship_check,
        delete: :delete_check,
        integrate: :integrate_check
      }.freeze

      def call
        return failed_response 'Sales Order record not found' unless @entity || task == :create

        check = CHECKS[task]
        raise ArgumentError, "Task \"#{task}\" is unknown for #{self.class}" if check.nil?

        send(check)
      end

      private

      def create_check
        all_ok
      end

      def edit_check
        all_ok
      end

      def delete_check
        return failed_response 'Sales Order has been shipped' if shipped?

        all_ok
      end

      def ship_check
        fail_message = shipped? ? 'Sales Order has already been shipped' : nil
        fail_message ||= 'User is not allowed to ship Sales Orders' unless can_user_ship?
        fail_message ||= 'Sales Order has no items' if no_items?
        fail_message ||= 'Sales Order items are missing some quantities' if incomplete_items?
        return failed_response(fail_message) if fail_message

        all_ok
      end

      def integrate_check
        return failed_response 'Sales Order has not been shipped' unless shipped?
        return failed_response('Sales Order has already been integrated') if integrated?

        all_ok
      end

      def shipped?
        @entity.shipped
      end

      def no_items?
        @repo.for_select_mr_sales_order_items(where: { mr_sales_order_id: @id }).none?
      end

      def incomplete_items?
        @repo.for_select_mr_sales_order_items(where: { mr_sales_order_id: @id, quantity_required: nil }).any?
      end

      def can_user_ship?
        return false unless @user

        Crossbeams::Config::UserPermissions.can_user?(@user, :mr_sales_orders, :ship)
      end

      def integrated?
        @entity.integration_completed
      end
    end
  end
end
