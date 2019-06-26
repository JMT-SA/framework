# frozen_string_literal: true

module UiRules
  class MrDeliveryItemRule < Base
    def generate_rules
      @repo = PackMaterialApp::ReplenishRepo.new
      make_form_object
      apply_form_values
      add_over_under_supply_values if @options && @options[:form_values]

      common_values_for_fields @mode == :preselect ? preselect_fields : common_fields

      set_show_fields if @mode == :show
      add_preselect_behaviours if @mode == :preselect
      add_new_item_behaviours if @mode == :new || @mode == :edit

      form_name 'mr_delivery_item'
    end

    def set_show_fields
      fields[:mr_product_variant_code] = { renderer: :label, with_value: product_variant_code, caption: 'Product Code' }
      fields[:quantity_on_note] = { renderer: :label }
      fields[:quantity_over_supplied] = { renderer: :label, caption: 'PO Over Supplied' }
      fields[:quantity_under_supplied] = { renderer: :label, caption: 'PO Under Supplied' }
      fields[:quantity_received] = { renderer: :label }
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
        quantity_over_supplied: { renderer: :label, caption: 'PO Over Supplied' },
        quantity_under_supplied: { renderer: :label, caption: 'PO Under Supplied' },
        quantity_received: { renderer: :numeric, required: true },
        invoiced_unit_price: { renderer: :numeric },
        remarks: {}
      }
    end

    def preselect_fields
      {
        purchase_order_id: {
          renderer: :select,
          options: @repo.for_select_purchase_orders_with_supplier(purchase_order_id: @options[:purchase_order_id]),
          selected: @options[:purchase_order_id],
          caption: 'Purchase Order',
          required: true,
          prompt: true
        },
        mr_delivery_id: { renderer: :hidden },
        mr_purchase_order_item_id: {
          renderer: :select,
          options: @options[:purchase_order_id] ? available_purchase_order_items : nil,
          caption: 'Item',
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
                                    quantity_on_note: nil,
                                    quantity_over_supplied: nil,
                                    quantity_under_supplied: nil,
                                    quantity_received: nil,
                                    invoiced_unit_price: unit_price,
                                    remarks: nil)
    end

    def add_over_under_supply_values
      @form_object = OpenStruct.new(@form_object)
      hash_quantities = @repo.over_under_supply(@form_object.quantity_received, @form_object.mr_purchase_order_item_id)

      %i[quantity_over_supplied quantity_under_supplied].each do |k|
        @form_object.public_send("#{k}=", hash_quantities[k])
      end
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
      url         = "/pack_material/replenish/mr_deliveries/#{delivery_id}/mr_delivery_items/quantity_received_changed"
      behaviours do |behaviour|
        behaviour.keyup :quantity_received, notify: [{ url: url, param_keys: [:mr_delivery_item_mr_purchase_order_item_id] }]
      end
    end
  end
end
