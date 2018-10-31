# frozen_string_literal: true

module UiRules
  class MrPurchaseOrderCostRule < Base
    def generate_rules
      @repo = PackMaterialApp::ReplenishRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'mr_purchase_order_cost'
    end

    def set_show_fields
      # mr_cost_type_id_label = PackMaterialApp::MrCostTypeRepo.new.find_mr_cost_type(@form_object.mr_cost_type_id)&.cost_code_string
      mr_cost_type_id_label = @repo.find(:mr_cost_types, PackMaterialApp::MrCostType, @form_object.mr_cost_type_id)&.cost_code_string
      # mr_purchase_order_id_label = PackMaterialApp::MrPurchaseOrderRepo.new.find_mr_purchase_order(@form_object.mr_purchase_order_id)&.purchase_account_code
      mr_purchase_order_id_label = @repo.find(:mr_purchase_orders, PackMaterialApp::MrPurchaseOrder, @form_object.mr_purchase_order_id)&.purchase_account_code
      fields[:mr_cost_type_id] = { renderer: :label, with_value: mr_cost_type_id_label, caption: 'Mr Cost Type' }
      fields[:mr_purchase_order_id] = { renderer: :label, with_value: mr_purchase_order_id_label, caption: 'Mr Purchase Order' }
      fields[:amount] = { renderer: :label }
    end

    def common_fields
      {
        mr_cost_type_id: { renderer: :select, options: PackMaterialApp::MrCostTypeRepo.new.for_select_mr_cost_types, caption: 'Mr Cost Type' },
        mr_purchase_order_id: { renderer: :select, options: PackMaterialApp::MrPurchaseOrderRepo.new.for_select_mr_purchase_orders, caption: 'Mr Purchase Order' },
        amount: {}
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_mr_purchase_order_cost(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(mr_cost_type_id: nil,
                                    mr_purchase_order_id: nil,
                                    amount: nil)
    end
  end
end
