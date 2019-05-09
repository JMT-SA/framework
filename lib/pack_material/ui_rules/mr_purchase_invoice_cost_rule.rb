# frozen_string_literal: true

module UiRules
  class MrPurchaseInvoiceCostRule < Base
    def generate_rules
      @repo = PackMaterialApp::ReplenishRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'mr_purchase_invoice_cost'
    end

    def set_show_fields
      mr_cost_type_id_label = @repo.find_mr_cost_type(@form_object.mr_cost_type_id)&.cost_type_code
      fields[:mr_cost_type_id] = { renderer: :label, with_value: mr_cost_type_id_label, caption: 'Cost Type' }
      fields[:mr_delivery_id] = { renderer: :hidden }
      fields[:amount] = { renderer: :label }
    end

    def common_fields
      {
        mr_cost_type_id: { renderer: :select, options: @repo.for_select_mr_cost_types, caption: 'Cost Type' },
        mr_delivery_id: { renderer: :hidden },
        amount: { renderer: :numeric }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_mr_purchase_invoice_cost(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(mr_cost_type_id: nil,
                                    mr_delivery_id: @options[:delivery_id],
                                    amount: nil)
    end
  end
end
