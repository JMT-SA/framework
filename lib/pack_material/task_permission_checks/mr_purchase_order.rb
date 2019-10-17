# frozen_string_literal: true

module PackMaterialApp
  module TaskPermissionCheck
    class MrPurchaseOrder < BaseService
      attr_reader :task, :entity

      def initialize(task, purchase_order_id = nil, current_user = nil)
        @task   = task
        @repo   = ReplenishRepo.new
        @id     = purchase_order_id
        @entity = @id ? @repo.find_mr_purchase_order(purchase_order_id) : nil
        @user   = current_user
      end

      def call # rubocop:disable Metrics/CyclomaticComplexity
        return failed_response 'Record not found' unless @entity || task == :create

        case task
        when :create
          create_check
        when :short_supplied
          short_supplied_check
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
        return failed_response 'User is not allowed to approve Purchase Orders' unless can_user_approve?
        return failed_response('Purchase Order has no items') if no_items?
        return all_ok if no_purchase_order_number?
        return failed_response('Purchase Order is already approved') if approved?

        all_ok
      end

      def short_supplied_check # rubocop:disable Metrics/CyclomaticComplexity
        return failed_response('User is not allowed to mark as short supplied') unless can_user_short_supply?
        return failed_response('Purchase Order has no items') if no_items?
        return failed_response('Purchase Order has not been approved yet') unless approved?
        return failed_response('Purchase Order has already been completed') if deliveries_received?
        return failed_response('Purchase Order is already short_supplied') if short_supplied?
        return failed_response('Purchase Order has not received any deliveries yet') unless deliveries_has_been_received?

        all_ok
      end

      def approved?
        @entity.approved
      end

      def short_supplied?
        @entity.short_supplied
      end

      def deliveries_received?
        @entity.deliveries_received
      end

      def deliveries_has_been_received?
        @repo.deliveries_for_purchase_order_check(@id)
      end

      def no_items?
        @repo.mr_purchase_order_items(@id).empty?
      end

      def no_purchase_order_number?
        @entity.purchase_order_number.nil?
      end

      def can_user_approve?
        Crossbeams::Config::UserPermissions.can_user?(@user, :purchase_order, :approve)
      end

      def can_user_short_supply?
        Crossbeams::Config::UserPermissions.can_user?(@user, :purchase_order, :short_supplied)
      end
    end
  end
end
