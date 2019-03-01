# frozen_string_literal: true

module UiRules
  class MrBulkStockAdjustmentItemRule < Base
    def generate_rules
      @repo = PackMaterialApp::TransactionsRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields @mode == :new ? new_fields : common_fields

      set_show_fields if %i[show reopen].include? @mode
      set_complete_fields if @mode == :complete

      set_approve_fields if @mode == :approve
      add_approve_behaviours if @mode == :approve

      form_name 'mr_bulk_stock_adjustment_item'
    end

    def set_show_fields
      # mr_bulk_stock_adjustment_id_label = PackMaterialApp::MrBulkStockAdjustmentRepo.new.find_mr_bulk_stock_adjustment(@form_object.mr_bulk_stock_adjustment_id)&.location_long_codes
      mr_bulk_stock_adjustment_id_label = @repo.find(:mr_bulk_stock_adjustments, PackMaterialApp::MrBulkStockAdjustment, @form_object.mr_bulk_stock_adjustment_id)&.location_long_codes
      # mr_sku_location_id_label = PackMaterialApp::MrSkuLocationRepo.new.find_mr_sku_location(@form_object.mr_sku_location_id)&.id
      mr_sku_location_id_label = @repo.find(:mr_sku_locations, PackMaterialApp::MrSkuLocation, @form_object.mr_sku_location_id)&.id
      fields[:mr_bulk_stock_adjustment_id] = { renderer: :label, with_value: mr_bulk_stock_adjustment_id_label, caption: 'Bulk Stock Adjustment' }
      fields[:mr_sku_location_id] = { renderer: :label, with_value: mr_sku_location_id_label, caption: 'SKU Location' }
      fields[:sku_number] = { renderer: :label }
      fields[:product_variant_number] = { renderer: :label }
      fields[:product_number] = { renderer: :label }
      fields[:mr_type_name] = { renderer: :label }
      fields[:mr_sub_type_name] = { renderer: :label }
      fields[:product_variant_code] = { renderer: :label }
      fields[:product_code] = { renderer: :label }
      fields[:location_long_code] = { renderer: :label }
      fields[:inventory_uom_code] = { renderer: :label }
      fields[:scan_to_location_long_code] = { renderer: :label }
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
        mr_bulk_stock_adjustment_id: { renderer: :hidden },
        mr_sku_location_id: { renderer: :hidden },
        sku_number: { renderer: :label },
        location_long_code: { renderer: :label },
        scan_to_location_long_code: {}, # ???
        product_variant_number: { renderer: :label },
        product_number: { renderer: :label },
        mr_type_name: { required: true, caption: 'Type Name', renderer: :label },
        mr_sub_type_name: { required: true, caption: 'Sub Type Name', renderer: :label },
        product_variant_code: { required: true, renderer: :label },
        product_code: { required: true, renderer: :label },
        inventory_uom_code: { caption: 'UOM Code' },
        system_quantity: {},
        actual_quantity: {},
        stock_take_complete: { renderer: :checkbox }
      }
    end

    def new_fields
      {
        mr_bulk_stock_adjustment_id: { renderer: :hidden },
        sku_location_lookup: { renderer: :lookup,
                               lookup_name: :sku_locations,
                               lookup_key: :standard,
                               caption: 'Select SKU Location',
                               param_values: {
                                 allowed_sku_numbers: sku_number_options.map { |r| r[0] },
                                 allowed_locations: location_options.map { |r| r[1] }
                               }
        },
        mr_sku_id: { renderer: :select, options: sku_number_options, caption: 'SKU Number' },
        location_id: { renderer: :select, options: location_options, caption: 'Location Code' }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_mr_bulk_stock_adjustment_item(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(mr_bulk_stock_adjustment_id: @options[:parent_id],
                                    mr_sku_location_id: nil,
                                    sku_number: sku_number_options.first,
                                    location_long_code: location_options.first)
    end

    def bulk_stock_adjustment_id
      @options[:parent_id] || @form_object.mr_bulk_stock_adjustment_id
    end

    def mr_sku_location_options
      options = @repo.for_select_mr_sku_locations(where: { mr_sku_id: @repo.bulk_stock_adjustment_sku_ids(bulk_stock_adjustment_id) })
      ['none'] + options
    end

    def sku_number_options
      @repo.bulk_stock_adjustment_sku_numbers(bulk_stock_adjustment_id)
    end

    def location_options
      @repo.bulk_stock_adjustment_locations(bulk_stock_adjustment_id)
    end

    private

    def add_approve_behaviours
      behaviours do |behaviour|
        behaviour.enable :reject_reason, when: :approve_action, changes_to: ['r']
      end
    end
  end
end
