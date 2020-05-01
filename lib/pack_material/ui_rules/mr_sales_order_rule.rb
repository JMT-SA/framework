# frozen_string_literal: true

module UiRules
  class MrSalesOrderRule < Base
    def generate_rules # rubocop:disable Metrics/AbcSize
      @repo = PackMaterialApp::DispatchRepo.new
      @party_repo = MasterfilesApp::PartyRepo.new
      @general_repo = MasterfilesApp::GeneralRepo.new
      @replenish_repo = PackMaterialApp::ReplenishRepo.new
      @perm = PackMaterialApp::TaskPermissionCheck::MrSalesOrder
      make_form_object
      apply_form_values

      set_rules unless @mode == :new

      common_values_for_fields case @mode
                               when :new
                                 new_fields
                               else
                                 rules[:shipped] ? common_fields.merge(show_fields) : common_fields.merge(edit_fields)
                               end

      form_name 'mr_sales_order'
    end

    def set_rules
      rules[:shipped] = @form_object.shipped unless @mode == :new
      rules[:can_ship] = can_ship
      rules[:ready_to_ship] = ready_to_ship
      rules[:invoice_completed] = @form_object.integration_completed
      rules[:can_complete_invoice] = can_complete_invoice
      rules[:so_sub_totals] = @repo.so_sub_totals(@options[:id]) unless @mode == :new
    end

    def show_fields
      dispatch_loc = @replenish_repo.location_long_code_from_location_id(@form_object.dispatch_location_id)
      account_code_id_label = @repo.find(:account_codes, MasterfilesApp::AccountCode, @form_object.account_code_id)&.description
      {
        vat_type_id: { renderer: :label, with_value: @replenish_repo.find_mr_vat_type(@form_object.vat_type_id)&.vat_type_code, caption: 'Vat Type' },
        dispatch_location_id: { renderer: :label, with_value: dispatch_loc },
        fin_object_code: { renderer: :label },
        client_reference_number: { renderer: :label },
        valid_until: { renderer: :label },
        account_code_id: { renderer: :label, with_value: account_code_id_label, caption: 'Account Code' }
      }
    end

    def new_fields
      {
        customer_party_role_id: {
          renderer: :select,
          options: @party_repo.for_select_party_roles(AppConst::ROLE_CUSTOMER),
          caption: 'Please select Customer',
          required: true
        }
      }
    end

    def edit_fields
      fields = {
        dispatch_location_id: { renderer: :select, options: @repo.dispatch_locations, selected: @form_object&.dispatch_location_id, readonly: @form_object.shipped, required: true, prompt: true },
        vat_type_id: { renderer: :select, options: @replenish_repo.for_select_mr_vat_types, selected: @form_object&.vat_type_id, caption: 'Vat Type', required: true, prompt: true },
        account_code_id: { renderer: :select, options: @general_repo.for_select_account_codes_with_descriptions, selected: @form_object&.account_code_id, caption: 'Account Code', required: true, prompt: true },
        fin_object_code: {},
        client_reference_number: { required: true }
      }
      fields.merge(common_fields)
    end

    def common_fields
      {
        customer_party_role_id: { renderer: :hidden },
        issue_transaction_id: { renderer: :hidden },
        erp_customer_number: { renderer: :label },
        created_by: { renderer: :label },
        sales_order_number: { renderer: :label },
        shipped_at: { renderer: :label },
        integration_error: { renderer: :hidden },
        integration_completed: { renderer: :label, as_boolean: true, caption: 'Sent to ERP system' },
        shipped: { renderer: :label, as_boolean: true },
        erp_invoice_number: { renderer: :label },
        status: { renderer: :label }
      }
    end

    def make_form_object
      @form_object = if @mode == :new
                       OpenStruct.new(customer_party_role_id: nil)
                     else
                       @form_object = @repo.find_mr_sales_order(@options[:id])
                     end
    end

    private

    def ready_to_ship
      res = @perm.call(:ready_to_ship, @options[:id])
      res.success
    end

    def can_ship
      res = @perm.call(:can_ship, @options[:id], current_user: @options[:current_user])
      res.success
    end

    def can_complete_invoice
      res = @perm.call(:integrate, @options[:id], current_user: @options[:current_user])
      return false if @mode == :edit && already_enqueued?(@options[:id])

      res.success
    end

    def already_enqueued?(mr_sales_order_id)
      PackMaterialApp::ERPPurchaseInvoiceJob.enqueued_with_args?(mr_sales_order_id: mr_sales_order_id)
    end

    # def add_approve_behaviours
    #   behaviours do |behaviour|
    #     behaviour.enable :reject_reason, when: :approve_action, changes_to: ['r']
    #   end
    # end
  end
end
