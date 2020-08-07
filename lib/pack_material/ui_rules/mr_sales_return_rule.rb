# frozen_string_literal: true

module UiRules
  class MrSalesReturnRule < Base
    def generate_rules
      @repo = PackMaterialApp::DispatchRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields @mode == :new ? new_fields : common_fields

      set_show_fields if %i[show reopen].include? @mode

      form_name 'mr_sales_return'
    end

    def set_show_fields
      # mr_sales_order_id_label = PackMaterialApp::MrSalesOrderRepo.new.find_mr_sales_order(@form_object.mr_sales_order_id)&.erp_customer_number
      mr_sales_order_id_label = @repo.find(:mr_sales_orders, PackMaterialApp::MrSalesOrder, @form_object.mr_sales_order_id)&.erp_customer_number
      # issue_transaction_id_label = PackMaterialApp::MrInventoryTransactionRepo.new.find_mr_inventory_transaction(@form_object.issue_transaction_id)&.created_by
      issue_transaction_id_label = @repo.find(:mr_inventory_transactions, PackMaterialApp::MrInventoryTransaction, @form_object.issue_transaction_id)&.created_by
      fields[:mr_sales_order_id] = { renderer: :label, with_value: mr_sales_order_id_label, caption: 'Mr Sales Order' }
      fields[:issue_transaction_id] = { renderer: :label, with_value: issue_transaction_id_label, caption: 'Issue Transaction' }
      fields[:created_by] = { renderer: :label }
      fields[:remarks] = { renderer: :label }
      fields[:sales_return_number] = { renderer: :label }
    end

    def new_fields
      {
        mr_sales_order_id: { renderer: :select, options: @repo.for_select_mr_sales_orders, caption: 'Sales Order', required: true }
      }
    end

    def common_fields
      {
        mr_sales_order_id: { renderer: :hidden },
        issue_transaction_id: { renderer: :hidden },
        created_by: { required: true },
        remarks: {},
        sales_return_number: {}
      }
    end

    def make_form_object
      if @mode == :new
        make_new_form_object
        return
      end

      @form_object = @repo.find_mr_sales_return(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(mr_sales_order_id: nil,
                                    issue_transaction_id: nil,
                                    created_by: nil,
                                    remarks: nil,
                                    sales_return_number: nil)
    end

    # private

    # def add_approve_behaviours
    #   behaviours do |behaviour|
    #     behaviour.enable :reject_reason, when: :approve_action, changes_to: ['r']
    #   end
    # end
  end
end
