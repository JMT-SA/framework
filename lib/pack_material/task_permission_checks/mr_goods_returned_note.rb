# frozen_string_literal: true

module PackMaterialApp
  module TaskPermissionCheck
    class MrGoodsReturnedNote < BaseService
      attr_reader :task, :entity
      def initialize(task, mr_goods_returned_note_id = nil, current_user: nil)
        @task = task
        @repo = DispatchRepo.new
        @id = mr_goods_returned_note_id
        @entity = @id ? @repo.find_mr_goods_returned_note(@id) : nil
        @user = current_user
      end

      CHECKS = {
        create: :create_check,
        edit: :edit_check,
        can_ship: :ship_check,
        delete: :delete_check,
        complete_invoice: :complete_invoice_check
      }.freeze

      def call
        return failed_response 'Goods Returned Note record not found' unless @entity || task == :create

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
        return failed_response 'Goods Returned Note has been shipped' if shipped?

        all_ok
      end

      def ship_check
        fail_message = shipped? ? 'GRN has already been shipped' : nil
        fail_message ||= 'User is not allowed to ship GRNs' unless can_user_ship?
        fail_message ||= 'GRN has no items' if no_items?
        fail_message ||= 'GRN items are missing some quantities' if incomplete_items?
        return failed_response(fail_message) if fail_message

        all_ok
      end

      def complete_invoice_check
        return failed_response 'Goods Returned Note has not been shipped' unless shipped?
        return failed_response('GRN Purchase Invoice has already been completed') if invoice_completed?

        all_ok
      end

      def shipped?
        @entity.shipped
      end

      def no_items?
        @repo.for_select_mr_goods_returned_note_items(where: { mr_goods_returned_note_id: @id }).none?
      end

      def incomplete_items?
        @repo.for_select_mr_goods_returned_note_items(where: { mr_goods_returned_note_id: @id, quantity_returned: nil }).any?
      end

      def can_user_ship?
        return false unless @user

        Crossbeams::Config::UserPermissions.can_user?(@user, :goods_returned_note, :ship)
      end

      def invoice_completed?
        @entity.invoice_completed
      end
    end
  end
end
