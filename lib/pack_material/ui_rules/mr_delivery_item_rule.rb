# frozen_string_literal: true

module UiRules
  class MrDeliveryItemRule < Base # rubocop:disable Metrics/ClassLength
    def generate_rules # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
      @repo = PackMaterialApp::ReplenishRepo.new
      make_form_object
      apply_form_values
      add_over_under_supply_values if @options[:form_values]

      common_values_for_fields @mode == :preselect ? preselect_fields : common_fields

      set_show_fields if @mode == :show
      add_preselect_behaviours if @mode == :preselect
      add_new_item_behaviours if @mode == :new || @mode == :edit

      form_name 'mr_delivery_item'
    end

    def set_show_fields
      fields[:mr_product_variant_code] = { renderer: :label, with_value: product_variant_code, caption: 'Product Code' }
      fields[:quantity_on_note] = { renderer: :label }
      fields[:quantity_received] = { renderer: :label }
      fields[:quantity_returned] = { renderer: :label }
      fields[:quantity_difference] = { renderer: :label }
      fields[:quantity_over_under_supplied] = { renderer: :label, caption: 'PO Over/Under Supplied' }
      fields[:invoiced_unit_price] = { renderer: :label }
      fields[:remarks] = { renderer: :label }
    end

    def common_fields
      {
        mr_delivery_id: { renderer: :hidden },
        mr_purchase_order_item_id: { renderer: :hidden },
        mr_product_variant_id: { renderer: :hidden },
        product_variant_code: { renderer: :label, with_value: product_variant_code },
        quantity_on_note: { renderer: :numeric, required: true },
        quantity_received: { renderer: :numeric, required: true },
        quantity_returned: { renderer: :numeric },
        quantity_difference_label: { renderer: :label, with_value: @form_object.quantity_difference.to_f, caption: 'Quantity Difference' },
        quantity_difference: { renderer: :hidden },
        quantity_over_under_supplied: { renderer: :label, caption: 'PO Over/Under Supplied' },
        invoiced_unit_price: { renderer: :numeric },
        remarks: { renderer: :textarea, rows: 5 }
      }
    end

    def preselect_fields
      {
        purchase_order_id: {
          renderer: :select,
          options: @repo.for_select_purchase_orders_with_supplier(purchase_order_id: @options[:purchase_order_id]),
          selected: @options[:purchase_order_id],
          caption: 'Purchase Order',
          searchable: false,
          required: true,
          prompt: true,
          sort_items: false
        },
        mr_delivery_id: { renderer: :hidden },
        mr_purchase_order_item_id: {
          renderer: :select,
          options: @options[:purchase_order_id] ? available_purchase_order_items : nil,
          caption: 'Item',
          min_charwidth: 40,
          searchable: false,
          required: true
        }
      }
    end

    def make_form_object
      make_preselect_form_object && return if @mode == :preselect
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_mr_delivery_item(@options[:id])
    end

    def make_preselect_form_object
      @form_object = OpenStruct.new(purchase_order_id: nil)
    end

    def make_new_form_object
      @form_object = OpenStruct.new(mr_delivery_id: @options[:parent_id],
                                    mr_purchase_order_item_id: @options[:item_id],
                                    mr_product_variant_id: product_variant_id,
                                    quantity_on_note: AppConst::BIG_ZERO,
                                    quantity_received: AppConst::BIG_ZERO,
                                    quantity_returned: AppConst::BIG_ZERO,
                                    quantity_difference: AppConst::BIG_ZERO,
                                    quantity_over_under_supplied: AppConst::BIG_ZERO,
                                    invoiced_unit_price: unit_price,
                                    remarks: nil)
    end

    def add_over_under_supply_values
      @form_object = OpenStruct.new(@form_object)
      @form_object[:quantity_over_under_supplied] = @repo.over_under_supply(@form_object.quantity_received, @form_object.mr_purchase_order_item_id)
    end

    def product_variant_code
      PackMaterialApp::ConfigRepo.new.find_matres_product_variant(@form_object.mr_product_variant_id)&.product_variant_code
    end

    def product_variant_id
      purchase_order_item&.mr_product_variant_id
    end

    def available_purchase_order_items
      @repo.for_select_remaining_purchase_order_items(@options[:purchase_order_id], @options[:parent_id])
    end

    def unit_price
      purchase_order_item&.unit_price
    end

    def purchase_order_item
      @purchase_order_item ||= @repo.find_mr_purchase_order_item(@options[:item_id])
    end

    def selected_purchase_order
      @options[:purchase_order_id]
    end

    def add_preselect_behaviours
      behaviours do |behaviour|
        behaviour.dropdown_change :purchase_order_id, notify: [{ url: "/pack_material/replenish/mr_deliveries/#{@options[:parent_id]}/mr_delivery_items/purchase_order_changed" }]
      end
    end

    def add_new_item_behaviours
      delivery_id = @options[:parent_id] || @form_object.mr_delivery_id
      url = "/pack_material/replenish/mr_deliveries/#{delivery_id}/mr_delivery_items/quantities_changed"
      keys = %i[
        mr_delivery_item_mr_purchase_order_item_id
        mr_delivery_item_quantity_received
        mr_delivery_item_quantity_on_note
        mr_delivery_item_quantity_returned
        mr_delivery_item_quantity_difference
      ]
      behaviours do |behaviour|
        behaviour.keyup :quantity_received, notify: [{ url: url, param_keys: keys }]
        behaviour.keyup :quantity_on_note, notify: [{ url: url, param_keys: keys }]
        behaviour.keyup :quantity_returned, notify: [{ url: url, param_keys: keys }]
      end
    end
  end
end
