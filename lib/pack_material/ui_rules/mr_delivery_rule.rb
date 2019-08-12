# frozen_string_literal: true

module UiRules
  class MrDeliveryRule < Base # rubocop:disable Metrics/ClassLength
    def generate_rules # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
      @repo = PackMaterialApp::ReplenishRepo.new
      @party_repo = MasterfilesApp::PartyRepo.new
      @locations_repo = MasterfilesApp::LocationRepo.new
      @perm = PackMaterialApp::TaskPermissionCheck::MrDelivery
      make_form_object
      apply_form_values
      set_rules unless @mode == :new

      common_values_for_fields case @mode
                               when :new
                                 new_fields
                               when :edit
                                 rules[:is_verified] ? show_fields : edit_fields
                               when :edit_invoice
                                 rules[:invoice_completed] ? show_invoice_fields : invoice_fields
                               else
                                 edit_fields
                               end

      form_name 'mr_delivery'
    end

    def set_rules # rubocop:disable Metrics/AbcSize
      rules[:can_verify] = can_verify
      rules[:can_review] = can_review
      rules[:can_add_invoice] = can_add_invoice
      rules[:can_complete_invoice] = can_complete_invoice
      rules[:invoice_completed] = @form_object.invoice_completed
      rules[:is_verified] = @form_object.verified
      rules[:over_supply_accepted] = @form_object.accepted_over_supply
      rules[:del_sub_totals] = @repo.del_sub_totals(@options[:id])
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
        waybill_number: { renderer: :label },
        vehicle_registration: { renderer: :label },
        supplier_invoice_ref_number: { renderer: :label },
        supplier_invoice_date: { renderer: :label },
        purchase_order_numbers: { renderer: :label, with_value: purchase_order_numbers }
      }
    end

    def new_fields
      common_fields.merge(
        mr_purchase_order_id: {
          renderer: :select,
          prompt: true,
          options: @repo.for_select_purchase_orders_with_supplier,
          caption: 'Purchase Order',
          sort_items: false
        }
      )
    end

    def edit_fields
      common_fields.merge(
        purchase_order_numbers: { renderer: :label, with_value: purchase_order_numbers }
      )
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
        vehicle_registration: { required: true }
      }
    end

    def invoice_fields
      {
        supplier_invoice_ref_number: { required: true, with_value: @form_object.supplier_invoice_ref_number },
        supplier_invoice_date: { subtype: :date, required: true }
      }
    end

    def show_invoice_fields
      {
        supplier_invoice_ref_number: { renderer: :label },
        supplier_invoice_date: { renderer: :label },
        erp_purchase_order_number: { renderer: :label },
        erp_purchase_invoice_number: { renderer: :label }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new
      make_new_invoice_form_object && return if @mode == :edit_invoice

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

    def make_new_invoice_form_object
      delivery     = @repo.find_mr_delivery(@options[:id])
      @form_object = if delivery.supplier_invoice_ref_number.nil?
                       OpenStruct.new(supplier_invoice_ref_number: nil,
                                      supplier_invoice_date: UtilityFunctions.weeks_since(Time.now, 1))
                     else
                       delivery
                     end
    end

    def can_review
      res = @perm.call(:review, @options[:id], current_user: @options[:current_user])
      res.success
    end

    def can_verify
      res = @perm.call(:verify, @options[:id])
      res.success
    end

    def can_add_invoice
      res = @perm.call(:add_invoice, @options[:id])
      res.success
    end

    def can_complete_invoice
      res = @perm.call(:complete_invoice, @options[:id])
      return false if @mode == :edit && already_enqueued?(@options[:id])

      res.success
    end

    def purchase_order_numbers
      @repo.purchase_order_numbers_for_delivery(@options[:id])
    end

    def already_enqueued?(delivery_id)
      PackMaterialApp::ERPPurchaseInvoiceJob.enqueued_with_args?(delivery_id: delivery_id)
    end
  end
end
