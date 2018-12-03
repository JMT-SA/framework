# frozen_string_literal: true

module UiRules
  class MrDeliveryRule < Base
    def generate_rules
      @repo = PackMaterialApp::ReplenishRepo.new
      @party_repo = MasterfilesApp::PartyRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'mr_delivery'
    end

    def set_show_fields
      fields[:transporter] = { renderer: :label }
      fields[:driver_name] = { renderer: :label }
      fields[:client_delivery_ref_number] = { renderer: :label }
      fields[:delivery_number] = { renderer: :label }
      fields[:vehicle_registration] = { renderer: :label }
      fields[:supplier_invoice_ref_number] = { renderer: :label }
    end

    def common_fields
      {
        transporter_party_role_id: { renderer: :select, options: @party_repo.for_select_party_roles(AppConst::ROLE_TRANSPORTER), caption: 'Transporter' },
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
                                    driver_name: nil,
                                    client_delivery_ref_number: nil,
                                    vehicle_registration: nil,
                                    supplier_invoice_ref_number: nil)
    end
  end
end
