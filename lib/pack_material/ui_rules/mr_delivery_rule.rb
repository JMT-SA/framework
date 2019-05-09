# frozen_string_literal: true

module UiRules
  class MrDeliveryRule < Base
    def generate_rules
      @repo = PackMaterialApp::ReplenishRepo.new
      @party_repo = MasterfilesApp::PartyRepo.new
      @locations_repo = MasterfilesApp::LocationRepo.new
      make_form_object
      apply_form_values

      rules[:can_verify] = can_verify unless @mode == :new
      rules[:show_only] = @form_object.verified if @mode == :edit
      common_values_for_fields case @mode
                               when :edit
                                 rules[:show_only] ? show_fields : common_fields
                               else
                                 common_fields
                               end

      form_name 'mr_delivery'
    end

    def show_fields
      receiving_bay_label = @locations_repo.find_location(@form_object.receipt_location_id)&.location_long_code
      {
        status: { renderer: :label },
        transporter: { renderer: :label },
        transporter_party_role_id: { renderer: :hidden },
        receipt_location_id: { renderer: :label, with_value: receiving_bay_label, caption: 'Receiving Bay' },
        driver_name: { renderer: :label },
        client_delivery_ref_number: { renderer: :label },
        delivery_number: { renderer: :label },
        vehicle_registration: { renderer: :label },
        supplier_invoice_ref_number: { renderer: :label }
      }
    end

    def common_fields
      {
        status: { renderer: :hidden },
        transporter: { renderer: :hidden },
        transporter_party_role_id: { renderer: :select, options: @party_repo.for_select_party_roles(AppConst::ROLE_TRANSPORTER), caption: 'Transporter' },
        receipt_location_id: { renderer: :select, options: @locations_repo.for_select_receiving_bays, caption: 'Receiving Bay', required: true },
        delivery_number: { renderer: :label, with_value: @form_object.delivery_number },
        driver_name: { required: true },
        client_delivery_ref_number: { required: true },
        vehicle_registration: { required: true },
        supplier_invoice_ref_number: {}
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_mr_delivery(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(transporter_party_role_id: nil,
                                    receipt_location_id: nil,
                                    driver_name: nil,
                                    client_delivery_ref_number: nil,
                                    vehicle_registration: nil,
                                    supplier_invoice_ref_number: nil)
    end

    def can_verify
      res = PackMaterialApp::TaskPermissionCheck::MrDelivery.call(:verify, @options[:id])
      res.success
    end
  end
end