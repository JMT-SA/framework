# frozen_string_literal: true

module UiRules
  class MrSalesReturnRule < Base
    def generate_rules  # rubocop:disable Metrics/AbcSize
      @repo = PackMaterialApp::SalesReturnRepo.new
      @dispatch_repo = PackMaterialApp::DispatchRepo.new
      @location_repo = MasterfilesApp::LocationRepo.new
      @perm = PackMaterialApp::TaskPermissionCheck::MrSalesReturn
      make_form_object
      apply_form_values
      set_rules if @mode == :edit

      common_values_for_fields case @mode
                               when :new
                                 new_fields
                               else
                                 rules[:verified] || rules[:completed] ? common_fields.merge(show_fields) : common_fields.merge(edit_fields)
                               end

      form_name 'mr_sales_return'
    end

    def set_rules
      rules[:verified] = @form_object.verified
      rules[:completed] = @form_object.completed
      rules[:can_verify_sales_return] = can_verify_sales_return
      rules[:can_complete_sales_return] = can_complete_sales_return
      rules[:sales_return_sub_totals] = @repo.sales_return_sub_totals(@options[:id])
    end

    def new_fields
      {
        mr_sales_order_id: { renderer: :select,
                             options: @dispatch_repo.for_select_mr_sales_orders(where: { shipped: true, returned: false }),
                             caption: 'Sales Order',
                             required: true }
      }
    end

    def edit_fields
      {
        remarks: { renderer: :textarea,
                   rows: 5 },
        receipt_location_id: { renderer: :select,
                               options: @location_repo.for_select_receiving_bays,
                               caption: 'Receiving Bay',
                               required: true },
        sales_return_number: { renderer: :hidden }
      }
    end

    def show_fields
      receiving_bay_label = @location_repo.find_location(@form_object.receipt_location_id)&.location_long_code
      {
        sales_return_number: { renderer: :label },
        receipt_location_id: { renderer: :label,
                               with_value: receiving_bay_label,
                               caption: 'Receiving Bay' },
        remarks: { renderer: :label }
      }
    end

    def common_fields
      {
        mr_sales_order_id: { renderer: :hidden },
        issue_transaction_id: { renderer: :hidden },
        created_by: { renderer: :label },
        sales_order_number: { renderer: :label,
                              with_value: sales_order_number }
      }
    end

    def make_form_object
      @form_object = if @mode == :new
                       OpenStruct.new(mr_sales_order_id: nil)
                     else
                       @repo.find_mr_sales_return(@options[:id])
                     end
    end

    private

    def can_verify_sales_return
      interactor.check_permission(:verify_sales_return, @options[:id]).success
    end

    def can_complete_sales_return
      interactor.check_permission(:complete_sales_return, @options[:id]).success
    end

    def interactor
      @interactor ||= @options[:interactor]
    end

    def sales_order_number
      @dispatch_repo.find_mr_sales_order(@form_object.mr_sales_order_id).sales_order_number
    end
  end
end
