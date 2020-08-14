# frozen_string_literal: true

module UiRules
  class MrSalesReturnItemRule < Base
    def generate_rules
      @repo = PackMaterialApp::SalesReturnRepo.new
      make_form_object
      apply_form_values

      rules[:zero_options] = allowed_options.none? if @mode == :new
      common_values_for_fields @mode == :new ? new_fields : common_fields

      form_name 'mr_sales_return_item'
    end

    def new_fields
      {
        mr_sales_order_item_id: { renderer: :select,
                                  options: allowed_options,
                                  caption: 'Sales Order Item',
                                  required: true }
      }
    end

    def common_fields
      {
        mr_sales_return_id: { renderer: :hidden },
        mr_sales_order_item_id: { renderer: :hidden },
        remarks: {},
        quantity_returned: {}
      }
    end

    def make_form_object
      @form_object = if @mode == :new
                       OpenStruct.new(mr_sales_return_id: nil,
                                      mr_sales_order_item_id: nil,
                                      remarks: nil,
                                      quantity_returned: nil)
                     else
                       @repo.find_mr_sales_return_item(@options[:id])
                     end
    end

    def allowed_options
      @repo.sales_returns_item_options(@options[:parent_id])
    end
  end
end
