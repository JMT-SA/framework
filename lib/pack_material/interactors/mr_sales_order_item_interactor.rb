# frozen_string_literal: true

module PackMaterialApp
  class MrSalesOrderItemInteractor < BaseInteractor
    def create_mr_sales_order_item(parent_id, params) # rubocop:disable Metrics/AbcSize
      assert_permission!(:create, nil, sales_order_id: parent_id)
      attrs = params.merge(mr_sales_order_id: parent_id)
      res = validate_mr_sales_order_item_params(attrs)
      return validation_failed_response(res) unless res.messages.empty?

      res1 = validate_mr_sales_order_item_quantity_required(res)
      return validation_failed_response(OpenStruct.new(messages: { quantity_required: [res1.message] })) unless res1.success

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
      validation_failed_response(OpenStruct.new(messages: { base: ['This Sales Order Item already exists'] }))
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def update_mr_sales_order_item(id, params)
      res = validate_mr_sales_order_item_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      repo.transaction do
        repo.update_mr_sales_order_item(id, res)
        log_transaction
      end
      instance = mr_sales_order_item(id)
      success_response("Updated Sales Order Item #{instance.product_variant_code}")
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def delete_mr_sales_order_item(id)
      pv_code = mr_sales_order_item(id)&.product_variant_code
      repo.transaction do
        repo.delete_mr_sales_order_item(id)
        log_status('mr_sales_order_items', id, 'DELETED')
        log_transaction
      end
      success_response("Deleted Sales Order Item for #{pv_code}")
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def inline_update(id, params)
      res = validate_mr_sales_order_item_inline_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      repo.transaction do
        repo.inline_update_sales_order_item(id, res)
        log_status('mr_sales_order_items', id, 'INLINE ADJUSTMENT')
        log_transaction
      end
      success_response('Updated Sales Order Item')
    rescue Crossbeam::InfoError => e
      failed_response(e.message)
    end

    def can_ship(parent_id)
      check_parent_permission(:can_ship, parent_id)
    end

    def check_parent_permission(task, id = nil)
      TaskPermissionCheck::MrSalesOrder.call(task, id, current_user: @user)
    end

    def assert_permission!(task, id = nil, sales_order_id: nil)
      res = check_permission(task, id, sales_order_id)
      raise Crossbeams::TaskNotPermittedError, res.message unless res.success
    end

    def check_permission(task, id = nil, sales_order_id = nil)
      TaskPermissionCheck::MrSalesOrderItem.call(task, id, sales_order_id: sales_order_id)
    end

    def mr_sales_order(id)
      repo.find_mr_sales_order(id)
    end

    def mr_sales_order_item(id)
      repo.find_mr_sales_order_item(id)
    end

    private

    def repo
      @repo ||= DispatchRepo.new
    end

    def validate_mr_sales_order_item_params(params)
      MrSalesOrderItemSchema.call(params)
    end

    def validate_mr_sales_order_item_inline_params(params)
      MrSalesOrderItemInlineSchema.call(params)
    end

    def validate_mr_sales_order_item_quantity_required(params)
      repo.validate_mr_sales_order_item_quantity_required(params)
    end
  end
end
