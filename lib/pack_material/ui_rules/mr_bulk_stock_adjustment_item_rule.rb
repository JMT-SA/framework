# frozen_string_literal: true

module UiRules
  class MrBulkStockAdjustmentItemRule < Base
    def generate_rules
      @repo = PackMaterialApp::TransactionsRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if %i[show reopen].include? @mode
      set_complete_fields if @mode == :complete
      set_approve_fields if @mode == :approve

      add_approve_behaviours if @mode == :approve

      form_name 'mr_bulk_stock_adjustment_item'
    end

    def set_show_fields
      # mr_bulk_stock_adjustment_id_label = PackMaterialApp::MrBulkStockAdjustmentRepo.new.find_mr_bulk_stock_adjustment(@form_object.mr_bulk_stock_adjustment_id)&.location_codes
      mr_bulk_stock_adjustment_id_label = @repo.find(:mr_bulk_stock_adjustments, PackMaterialApp::MrBulkStockAdjustment, @form_object.mr_bulk_stock_adjustment_id)&.location_codes
      # mr_sku_location_id_label = PackMaterialApp::MrSkuLocationRepo.new.find_mr_sku_location(@form_object.mr_sku_location_id)&.id
      mr_sku_location_id_label = @repo.find(:mr_sku_locations, PackMaterialApp::MrSkuLocation, @form_object.mr_sku_location_id)&.id
      fields[:mr_bulk_stock_adjustment_id] = { renderer: :label, with_value: mr_bulk_stock_adjustment_id_label, caption: 'Mr Bulk Stock Adjustment' }
      fields[:mr_sku_location_id] = { renderer: :label, with_value: mr_sku_location_id_label, caption: 'Mr Sku Location' }
      fields[:sku_number] = { renderer: :label }
      fields[:product_variant_number] = { renderer: :label }
      fields[:product_number] = { renderer: :label }
      fields[:mr_type_name] = { renderer: :label }
      fields[:mr_sub_type_name] = { renderer: :label }
      fields[:product_variant_code] = { renderer: :label }
      fields[:product_code] = { renderer: :label }
      fields[:location_code] = { renderer: :label }
      fields[:inventory_uom_code] = { renderer: :label }
      fields[:scan_to_location_code] = { renderer: :label }
      fields[:system_quantity] = { renderer: :label }
      fields[:actual_quantity] = { renderer: :label }
      fields[:stock_take_complete] = { renderer: :label, as_boolean: true }
      fields[:active] = { renderer: :label, as_boolean: true }
    end

    def set_approve_fields
      set_show_fields
      fields[:approve_action] = { renderer: :select, options: [%w[Approve a], %w[Reject r]], required: true }
      fields[:reject_reason] = { renderer: :textarea, disabled: true }
    end

    def set_complete_fields
      set_show_fields
      user_repo = DevelopmentApp::UserRepo.new
      fields[:to] = { renderer: :select, options: user_repo.email_addresses(user_email_group: AppConst::EMAIL_GROUP_MR_BULK_STOCK_ADJUSTMENT_ITEM_APPROVERS), caption: 'Email address of person to notify', required: true }
    end

    def common_fields
      {
        mr_bulk_stock_adjustment_id: { renderer: :select, options: PackMaterialApp::MrBulkStockAdjustmentRepo.new.for_select_mr_bulk_stock_adjustments, disabled_options: PackMaterialApp::MrBulkStockAdjustmentRepo.new.for_inactive_select_mr_bulk_stock_adjustments, caption: 'mr_bulk_stock_adjustment', required: true },
        mr_sku_location_id: { renderer: :select, options: PackMaterialApp::MrSkuLocationRepo.new.for_select_mr_sku_locations, caption: 'Mr Sku Location', required: true },
        sku_number: { required: true },
        product_variant_number: {},
        product_number: {},
        mr_type_name: { required: true },
        mr_sub_type_name: { required: true },
        product_variant_code: { required: true },
        product_code: { required: true },
        location_code: {},
        inventory_uom_code: {},
        scan_to_location_code: {},
        system_quantity: {},
        actual_quantity: {},
        stock_take_complete: { renderer: :checkbox }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_mr_bulk_stock_adjustment_item(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(mr_bulk_stock_adjustment_id: nil,
                                    mr_sku_location_id: nil,
                                    sku_number: nil,
                                    product_variant_number: nil,
                                    product_number: nil,
                                    mr_type_name: nil,
                                    mr_sub_type_name: nil,
                                    product_variant_code: nil,
                                    product_code: nil,
                                    location_code: nil,
                                    inventory_uom_code: nil,
                                    scan_to_location_code: nil,
                                    system_quantity: nil,
                                    actual_quantity: nil,
                                    stock_take_complete: nil)
    end

    private

    def add_approve_behaviours
      behaviours do |behaviour|
        behaviour.enable :reject_reason, when: :approve_action, changes_to: ['r']
      end
    end
  end
end
