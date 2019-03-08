# frozen_string_literal: true

module UiRules
  class MrPurchaseOrderItemRule < Base
    def generate_rules
      @config_repo = PackMaterialApp::ConfigRepo.new
      @repo = PackMaterialApp::ReplenishRepo.new
      @general_repo = MasterfilesApp::GeneralRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields @mode == :new ? new_fields : edit_fields

      set_show_fields if @mode == :show

      form_name 'mr_purchase_order_item'
    end

    def set_show_fields
      fields[:mr_purchase_order_id] = { renderer: :hidden }
      fields[:mr_product_variant_id] = { renderer: :label,
                                         with_value: product_variant_code,
                                         caption: 'Product Variant' }
      fields[:inventory_uom_id] = { renderer: :label,
                                    with_value: @general_repo.find_uom(@form_object.inventory_uom_id)&.uom_code,
                                    caption: 'Inventory Uom' }
      fields[:quantity_required] = { renderer: :label }
      fields[:unit_price] = { renderer: :label }
    end

    def common_fields
      {
        mr_purchase_order_id: { renderer: :hidden, with_value: @options[:parent_id] },
        mr_product_variant_id: { renderer: :hidden },
        inventory_uom_id: { renderer: :select, options: @general_repo.for_select_uoms, caption: 'Inventory Uom', required: true },
        quantity_required: { renderer: :numeric, required: true },
        unit_price: { renderer: :numeric, required: true }
      }
    end

    def edit_fields
      edit_fields = common_fields
      edit_fields[:mr_product_variant] = {
        renderer: :label,
        with_value: product_variant_code,
        caption: 'Product Variant',
        required: true
      }
      edit_fields
    end

    def new_fields
      new_fields = common_fields
      new_fields[:mr_product_variant_id] = {
        renderer: :select,
        options: product_variants,
        caption: 'Product Variant',
        required: true
      }
      new_fields
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_mr_purchase_order_item(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(mr_purchase_order_id: nil,
                                    mr_product_variant_id: nil,
                                    inventory_uom_id: nil,
                                    quantity_required: nil,
                                    unit_price: nil)
    end

    def product_variants
      @repo.for_select_po_product_variants(@options[:parent_id] || @form_object.mr_purchase_order_id)
    end

    def product_variant_code
      @config_repo.find_matres_product_variant(@form_object.mr_product_variant_id)&.product_variant_code
    end
  end
end
