# frozen_string_literal: true

module PackMaterialApp
  module TaskPermissionCheck
    class MrPurchaseOrder < BaseService
      attr_reader :task, :entity
      def initialize(task, purchase_order_id = nil)
        @task = task
        @repo = ReplenishRepo.new
        @id = purchase_order_id
        @entity = @id ? @repo.find_mr_purchase_order(purchase_order_id) : nil
      end

      def call
        return failed_response 'Record not found' unless @entity || task == :create
        case task
        when :create
          create_check
        when :update, :delete
          mutable_check
        when :approve
          approve_check
        else
          raise ArgumentError, "Task \"#{task}\" is unknown for #{self.class}"
        end
      end

      private

      def create_check
        all_ok
      end

      def mutable_check
        return failed_response "Approved Purchase Order can not be #{task}d" if approved?
        all_ok
      end

      def approve_check
        return all_ok if no_purchase_order_number?
        return failed_response('Purchase Order is already approved') if approved?
        return failed_response('Purchase Order has no items') if no_items?
        all_ok
      end

      def approved?
        @entity.approved
      end

      def no_items?
        @repo.mr_purchase_order_items(@id).empty?
      end

      def no_purchase_order_number?
        @entity.purchase_order_number.nil?
      end

      # def can_reopen_purchase_order?(purchase_order_id)
      #   approved = find_hash(:mr_purchase_orders, purchase_order_id)[:approved]
      #   receiving_deliveries = DB['SELECT']
      #   approved && !receiving_deliveries
      #   # approved && not currently receiving deliveries
      # end
    end
  end
end
