# frozen_string_literal: true

module PackMaterialApp
  class MrSalesOrderItemInteractor < BaseInteractor
    def create_mr_sales_order_item(parent_id, params) # rubocop:disable Metrics/AbcSize
      assert_permission!(:create, nil, sales_order_id: parent_id)
      attrs = params.merge(mr_sales_order_id: parent_id)
      res = validate_mr_sales_order_item_params(attrs)
      return validation_failed_response(res) unless res.messages.empty?

      id = nil
      repo.transaction do
        id = repo.create_mr_sales_order_item(res)
        log_status('mr_sales_order_items', id, 'CREATED')
        log_transaction
      end
      instance = mr_sales_order_item(id)
      success_response('Created Sales Order item', instance)
    rescue Crossbeams::TaskNotPermittedError => e
      failed_response(e.message)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { base: ['This sales order item already exists'] }))
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    # def update_mr_goods_returned_note_item(id, params)
    #   res = validate_mr_goods_returned_note_item_params(params)
    #   return validation_failed_response(res) unless res.messages.empty?
    #
    #   repo.transaction do
    #     repo.update_mr_goods_returned_note_item(id, res)
    #     log_transaction
    #   end
    #   instance = mr_goods_returned_note_item(id)
    #   success_response("Updated goods returned note item #{instance.remarks}", instance)
    # rescue Crossbeams::InfoError => e
    #   failed_response(e.message)
    # end
    #
    # def delete_mr_goods_returned_note_item(id)
    #   name = mr_goods_returned_note_item(id).remarks
    #   repo.transaction do
    #     repo.delete_mr_goods_returned_note_item(id)
    #     log_status('mr_goods_returned_note_items', id, 'DELETED')
    #     log_transaction
    #   end
    #   success_response("Deleted goods returned note item #{name}")
    # rescue Crossbeams::InfoError => e
    #   failed_response(e.message)
    # end
    #
    # def assert_permission!(task, id = nil, grn_id: nil)
    #   res = check_permission(task, id, grn_id)
    #   raise Crossbeams::TaskNotPermittedError, res.message unless res.success
    # end
    #
    # def inline_update(id, params)
    #   remarks = params[:column_name] == 'remarks'
    #   res = remarks ? validate_inline_update_remarks_params(params) : validate_inline_update_quantity_params(params)
    #   return validation_failed_response(res) unless res.messages.empty?
    #
    #   repo.transaction do
    #     repo.inline_update_goods_returned_note(id, res)
    #     log_status('mr_goods_returned_notes', id, 'INLINE ADJUSTMENT')
    #     log_transaction
    #   end
    #   success_response('Updated Goods Returned Note Item')
    # rescue Crossbeams::InfoError => e
    #   failed_response(e.message)
    # end
    #
    # def can_ship(parent_id)
    #   check_parent_permission(:can_ship, parent_id)
    # end
    #
    # def check_permission(task, id = nil, grn_id = nil)
    #   TaskPermissionCheck::MrGoodsReturnedNoteItem.call(task, id, grn_id: grn_id)
    # end
    #
    # def check_parent_permission(task, id = nil)
    #   TaskPermissionCheck::MrGoodsReturnedNote.call(task, id, current_user: @user)
    # end
    #
    # def mr_goods_returned_note_item(id)
    #   repo.find_mr_goods_returned_note_item(id)
    # end
    #
    # def allowed_options(parent_id)
    #   repo.goods_returned_note_item_options(parent_id)
    # end
    #
    # private
    #
    # def repo
    #   @repo ||= SalesRepo.new
    # end
    #
    # def validate_mr_goods_returned_note_item_params(params)
    #   MrGoodsReturnedNoteItemSchema.call(params)
    # end
    #
    # def validate_inline_update_quantity_params(params)
    #   MrGoodsReturnedNoteItemInlineQuantitySchema.call(params)
    # end
    #
    # def validate_inline_update_remarks_params(params)
    #   MrGoodsReturnedNoteItemInlineRemarksSchema.call(params)
    # end

    def assert_permission!(task, id = nil, sales_order_id: nil)
      res = TaskPermissionCheck::MrSalesOrder.call(task, id, sales_order_id: sales_order_id)
      raise Crossbeams::TaskNotPermittedError, res.message unless res.success
    end

    private

    def repo
      @repo ||= SalesRepo.new
    end

    def mr_sales_order(id)
      repo.find_mr_sales_order(id)
    end

    def validate_mr_sales_order_params(params)
      MrSalesOrderSchema.call(params)
    end
  end
end
