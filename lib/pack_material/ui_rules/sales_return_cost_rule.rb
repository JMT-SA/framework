# frozen_string_literal: true

module UiRules
  class SalesReturnCostRule < Base
    def generate_rules
      @repo = PackMaterialApp::SalesReturnRepo.new
      @replenish_repo = PackMaterialApp::ReplenishRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      form_name 'sales_return_cost'
    end

    def common_fields
      {
        mr_sales_return_id: { renderer: :hidden },
        mr_cost_type_id: { renderer: :select,
                           options: @replenish_repo.for_select_mr_cost_types,
                           caption: 'Cost Type',
                           required: true },
        amount: { renderer: :numeric,
                  required: true }
      }
    end

    def make_form_object
      if @mode == :new
        make_new_form_object
        return
      end

      @form_object = @repo.find_sales_return_cost(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(mr_sales_return_id: nil,
                                    mr_cost_type_id: nil,
                                    amount: nil)
    end
  end
end
