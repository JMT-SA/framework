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

      rules[:shipped] = @form_object.shipped unless @mode == :new
      rules[:can_ship] = can_ship

      common_values_for_fields case @mode
                               when :new
                                 new_fields
                               else
                                 rules[:shipped] ? common_fields.merge(show_fields) : common_fields.merge(edit_fields)
                               end

      form_name 'mr_sales_order'
    end

    def show_fields
      dispatch_loc = @replenish_repo.location_long_code_from_location_id(@form_object.dispatch_location_id)
      account_code_id_label = @repo.find(:account_codes, MasterfilesApp::AccountCode, @form_object.account_code_id)&.description
      {
        vat_type_id: { renderer: :label, with_value: @replenish_repo.find_mr_vat_type(@form_object.vat_type_id)&.vat_type_code, caption: 'Vat Type' },
        dispatch_location_id: { renderer: :label, with_value: dispatch_loc },
        fin_object_code: { renderer: :label },
        valid_until: { renderer: :label },
        account_code_id: { renderer: :label, with_value: account_code_id_label, caption: 'Account Code' }
      }
    end

    def new_fields
      {
        customer_party_role_id: { renderer: :select, options: @party_repo.for_select_party_roles(AppConst::ROLE_CUSTOMER), caption: 'Please select Customer', required: true }
      }
    end

    def edit_fields
      fields = {
        dispatch_location_id: { renderer: :select, options: @repo.dispatch_locations, selected: @form_object.dispatch_location_id, readonly: @form_object.shipped },
        vat_type_id: { renderer: :select, options: @replenish_repo.for_select_mr_vat_types, caption: 'Vat Type', required: true },
        account_code_id: { renderer: :select, options: @general_repo.for_select_account_codes_with_descriptions, selected: @form_object&.account_code_id, caption: 'Account Code' },
        fin_object_code: {},
        valid_until: { subtype: :date, required: true }
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
        integration_completed: { renderer: :label, as_boolean: true },
        shipped: { renderer: :label, as_boolean: true }
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

    def can_ship
      res = @perm.call(:can_ship, @options[:id], current_user: @options[:current_user])
      res.success
    end

    # def add_approve_behaviours
    #   behaviours do |behaviour|
    #     behaviour.enable :reject_reason, when: :approve_action, changes_to: ['r']
    #   end
    # end
  end
end
