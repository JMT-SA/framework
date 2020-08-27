# frozen_string_literal: true

module PackMaterialApp
  module TaskPermissionCheck
    class SalesReturnCost < BaseService
      attr_reader :task, :entity
      def initialize(task, sales_return_cost_id = nil)
        @task = task
        @repo = SalesReturnRepo.new
        @id = sales_return_cost_id
        @entity = @id ? @repo.find_sales_return_cost(@id) : nil
      end

      CHECKS = {
        create: :create_check,
        edit: :edit_check,
        delete: :delete_check
      }.freeze

      def call
        return failed_response 'Sales Return Cost record not found' unless @entity || task == :create

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
        all_ok
      end
    end
  end
end
