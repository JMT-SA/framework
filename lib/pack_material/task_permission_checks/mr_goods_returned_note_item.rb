# frozen_string_literal: true

module PackMaterialApp
  module TaskPermissionCheck
    class MrGoodsReturnedNoteItem < BaseService
      attr_reader :task, :entity
      def initialize(task, grn_item_id = nil, grn_id: nil)
        @task = task
        @repo = DispatchRepo.new
        @id = grn_item_id
        @entity = @id ? @repo.find_mr_goods_returned_note_item(@id) : nil
        @grn_id = grn_id
        @grn = goods_returned_note
      end

      CHECKS = {
        create: :create_check,
        edit: :edit_check,
        delete: :delete_check
      }.freeze

      def call
        return failed_response 'Goods Returned Note Item record not found' unless @entity || task == :create

        check = CHECKS[task]
        raise ArgumentError, "Task \"#{task}\" is unknown for #{self.class}" if check.nil?

        send(check)
      end

      private

      def create_check
        return failed_response 'GRN has already been shipped' if grn_shipped?

        all_ok
      end

      def edit_check
        return failed_response 'GRN has already been shipped' if grn_shipped?

        all_ok
      end

      def delete_check
        return failed_response 'GRN has already been shipped' if grn_shipped?

        all_ok
      end

      def grn_shipped?
        @grn.shipped
      end

      def goods_returned_note
        @repo.find_mr_goods_returned_note(@grn_id || @entity.mr_goods_returned_note_id)
      end
    end
  end
end
