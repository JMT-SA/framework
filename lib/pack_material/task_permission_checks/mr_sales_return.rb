# frozen_string_literal: true

module PackMaterialApp
  module TaskPermissionCheck
    class MrSalesReturn < BaseService
      attr_reader :task, :entity
      def initialize(task, mr_sales_return_id = nil, current_user: nil)
        @task = task
        @repo = SalesReturnRepo.new
        @id = mr_sales_return_id
        @entity = @id ? @repo.find_mr_sales_return(@id) : nil
        @user = current_user
      end

      CHECKS = {
        create: :create_check,
        edit: :edit_check,
        delete: :delete_check,
        verify_sales_return: :verify_sales_return_check,
        complete_sales_return: :complete_sales_return_check
      }.freeze

      def call
        return failed_response 'Sales Return record not found' unless @entity || task == :create

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
        return failed_response 'Sales Return has been verified' if verified?

        all_ok
      end

      def verify_sales_return_check
        fail_message = verified? ? 'Sales Return has already been verified' : nil
        fail_message ||= 'User is not allowed to verify Sales Return' unless can_user_verify?
        fail_message ||= 'Sales Return has no items' if no_items?
        fail_message ||= 'Sales Return items are missing some quantities' if incomplete_items?
        return failed_response(fail_message) if fail_message

        all_ok
      end

      def complete_sales_return_check
        return failed_response 'Sales Return has not been verified' unless verified?
        return failed_response 'Sales Return has already been completed' if completed?
        return failed_response 'User is not allowed to integrate Sales Return' unless can_user_integrate?

        all_ok
      end

      def verified?
        @entity.verified
      end

      def can_user_verify?
        return false unless @user

        Crossbeams::Config::UserPermissions.can_user?(@user, :sales_return, :verify)
      end

      def can_user_integrate?
        return false unless @user

        Crossbeams::Config::UserPermissions.can_user?(@user, :sales_return, :integrate)
      end

      def no_items?
        @repo.for_select_mr_sales_return_items(where: { mr_sales_return_id: @id }).none?
      end

      def incomplete_items?
        @repo.for_select_mr_sales_return_items(where: { mr_sales_return_id: @id, quantity_returned: nil }).any?
      end

      def completed?
        @entity.completed
      end
    end
  end
end
