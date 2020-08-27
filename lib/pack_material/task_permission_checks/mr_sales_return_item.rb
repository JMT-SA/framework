# frozen_string_literal: true

module PackMaterialApp
  module TaskPermissionCheck
    class MrSalesReturnItem < BaseService
      attr_reader :task, :entity
      def initialize(task, mr_sales_return_item_id = nil, sales_return_id = nil)
        @task = task
        @repo = SalesReturnRepo.new
        @id = mr_sales_return_item_id
        @entity = @id ? @repo.find_mr_sales_return_item(@id) : nil
        @sales_return_id = sales_return_id
        @sales_return = mr_sale_return
      end

      CHECKS = {
        create: :create_check,
        edit: :edit_check,
        delete: :delete_check
      }.freeze

      def call
        return failed_response 'Sales Return Item record not found' unless @entity || task == :create

        check = CHECKS[task]
        raise ArgumentError, "Task \"#{task}\" is unknown for #{self.class}" if check.nil?

        send(check)
      end

      private

      def create_check
        return failed_response 'Sales Return has already been verified' if sales_return_verified?

        all_ok
      end

      def edit_check
        return failed_response 'Sales Return has already been verified' if sales_return_verified?

        all_ok
      end

      def delete_check
        return failed_response 'Sales Return has already been verified' if sales_return_verified?

        all_ok
      end

      def sales_return_verified?
        @sales_return.verified
      end

      def mr_sale_return
        @repo.find_mr_sales_return(@sales_return_id || @entity.mr_sales_return_id)
      end
    end
  end
end
