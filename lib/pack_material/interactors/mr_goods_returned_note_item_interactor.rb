# frozen_string_literal: true

module PackMaterialApp
  class MrGoodsReturnedNoteItemInteractor < BaseInteractor # rubocop:disable Metrics/ClassLength
    def create_mr_goods_returned_note_item(parent_id, params) # rubocop:disable Metrics/AbcSize
      assert_permission!(:create, nil, grn_id: parent_id)
      type, id = params[:delivery_item].split('_')
      attrs = { mr_goods_returned_note_id: parent_id }
      if type == 'item'
        attrs[:mr_delivery_item_id] = id
      else
        attrs[:mr_delivery_item_batch_id] = id
      end
      res = validate_mr_goods_returned_note_item_params(attrs)
      return validation_failed_response(res) unless res.messages.empty?

      id = nil
      repo.transaction do
        id = repo.create_mr_goods_returned_note_item(res)
        log_status('mr_goods_returned_note_items', id, 'CREATED')
        log_transaction
      end
      instance = mr_goods_returned_note_item(id)
      success_response("Created goods returned note item #{instance.remarks}", instance)
    rescue Crossbeams::TaskNotPermittedError => e
      failed_response(e.message)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { base: ['This goods returned note item already exists'] }))
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def update_mr_goods_returned_note_item(id, params) # rubocop:disable Metrics/AbcSize
      res = validate_mr_goods_returned_note_item_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      res = validate_grn_quantity_amount(id, params)
      return validation_failed_response(res) unless res.messages.empty?

      repo.transaction do
        repo.update_mr_goods_returned_note_item(id, res)
        log_transaction
      end
      instance = mr_goods_returned_note_item(id)
      success_response("Updated goods returned note item #{instance.remarks}", instance)
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def delete_mr_goods_returned_note_item(id)
      name = mr_goods_returned_note_item(id).remarks
      repo.transaction do
        repo.delete_mr_goods_returned_note_item(id)
        log_status('mr_goods_returned_note_items', id, 'DELETED')
        log_transaction
      end
      success_response("Deleted goods returned note item #{name}")
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def assert_permission!(task, id = nil, grn_id: nil)
      res = check_permission(task, id, grn_id)
      raise Crossbeams::TaskNotPermittedError, res.message unless res.success
    end

    def inline_update(id, params) # rubocop:disable Metrics/AbcSize
      remarks = params[:column_name] == 'remarks'
      res = remarks ? validate_inline_update_remarks_params(params) : validate_inline_update_quantity_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      unless remarks
        result = validate_grn_quantity_amount(id, params)
        return result unless result.success
      end

      repo.transaction do
        repo.inline_update_goods_returned_note(id, res)
        log_status('mr_goods_returned_note_items', id, 'INLINE ADJUSTMENT')
        log_transaction
      end
      success_response('Updated Goods Returned Note Item')
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def can_ship(parent_id)
      check_parent_permission(:can_ship, parent_id)
    end

    def check_permission(task, id = nil, grn_id = nil)
      TaskPermissionCheck::MrGoodsReturnedNoteItem.call(task, id, grn_id: grn_id)
    end

    def check_parent_permission(task, id = nil)
      TaskPermissionCheck::MrGoodsReturnedNote.call(task, id, current_user: @user)
    end

    def mr_goods_returned_note_item(id)
      repo.find_mr_goods_returned_note_item(id)
    end

    def allowed_options(parent_id)
      repo.goods_returned_note_item_options(parent_id)
    end

    private

    def repo
      @repo ||= DispatchRepo.new
    end

    def validate_mr_goods_returned_note_item_params(params)
      MrGoodsReturnedNoteItemSchema.call(params)
    end

    def validate_inline_update_quantity_params(params)
      MrGoodsReturnedNoteItemInlineQuantitySchema.call(params)
    end

    def validate_grn_quantity_amount(id, params)
      repo.validate_grn_quantity_amount(id, params)
    end

    def validate_inline_update_remarks_params(params)
      MrGoodsReturnedNoteItemInlineRemarksSchema.call(params)
    end
  end
end
