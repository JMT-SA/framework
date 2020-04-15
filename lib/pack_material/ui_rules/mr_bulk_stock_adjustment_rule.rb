# frozen_string_literal: true

module UiRules
  class MrBulkStockAdjustmentRule < Base # rubocop:disable Metrics/ClassLength
    def generate_rules # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      @repo = PackMaterialApp::TransactionsRepo.new
      @transaction_repo = PackMaterialApp::TransactionsRepo.new
      @perm = PackMaterialApp::TaskPermissionCheck::MrBulkStockAdjustment
      make_form_object
      apply_form_values

      if @mode == :edit
        rules[:can_integrate] = can_integrate
        rules[:can_sign_off] = can_sign_off
        rules[:can_complete] = can_complete
        rules[:can_approve] = can_approve
        rules[:can_manage_prices] = can_manage_prices
        rules[:show_only] = @form_object.completed || @form_object.approved
        rules[:signed_off] = @form_object.signed_off
        rules[:consumption] = @form_object.staging_consumption || @form_object.carton_assembly
        set_back_button
      end
      set_caption if @mode == :new

      common_values_for_fields case @mode
                               when :new
                                 new_fields
                               when :edit_header
                                 header_fields
                               when :edit
                                 rules[:show_only] ? show_fields : edit_fields
                               when :show
                                 view_header_fields
                               else
                                 new_fields
                               end

      form_name 'mr_bulk_stock_adjustment'
    end

    def set_back_button
      back_caption, completed_key, standard_key = if @form_object.carton_assembly
                                                    ['Back to Carton Assembly', 'carton_completed', 'carton_assembly']
                                                  elsif @form_object.staging_consumption
                                                    ['Back to Staging Consumption', 'staging_completed', 'staging_consumption']
                                                  else
                                                    ['Back to Bulk Stock Adjustments', 'completed', 'standard']
                                                  end
      rules[:back_caption] = back_caption
      rules[:back_link] = "/list/mr_bulk_stock_adjustments/with_params?key=#{@form_object.completed ? completed_key : standard_key}"
    end

    def set_caption
      rules[:caption] = case @options[:bsa_type]
                        when 'consumption'
                          'Start Consumption'
                        when 'carton_assembly'
                          'Carton Assembly'
                        else
                          'New Bulk Stock Adjustment'
                        end
    end

    def show_fields
      {
        stock_adjustment_number: { renderer: :label },
        ref_no: { renderer: :label },
        completed: { renderer: :label, as_boolean: true },
        approved: { renderer: :label, as_boolean: true },
        signed_off: { renderer: :label, as_boolean: true },
        integration_error: { renderer: :hidden },
        integration_completed: { renderer: :label, as_boolean: true, caption: 'Sent to ERP system' },
        status: { renderer: :label }
      }
    end

    def edit_fields
      {
        stock_adjustment_number: { renderer: :label },
        ref_no: { renderer: :label },
        completed: { renderer: :label, as_boolean: true },
        approved: { renderer: :label, as_boolean: true },
        signed_off: { renderer: :label, as_boolean: true },
        integration_error: { renderer: :hidden },
        integration_completed: { renderer: :label, as_boolean: true, caption: 'Sent to ERP system' },
        status: { renderer: :label }
      }
    end

    def header_fields
      {
        create_transaction_id: { renderer: :label, caption: 'Create Transaction' },
        destroy_transaction_id: { renderer: :label, caption: 'Destroy Transaction' },
        stock_adjustment_number: { renderer: :label },
        completed: { renderer: :hidden },
        approved: { renderer: :hidden },
        signed_off: { renderer: :hidden },
        business_process_id: { renderer: :select, options: @transaction_repo.for_select_bsa_business_processes, caption: 'Business Process', required: true },
        ref_no: { required: true },
        sku_numbers_list: { renderer: :list, items: sku_numbers, caption: 'SKU Numbers' },
        location_list: { renderer: :list, items: locations, caption: 'Location Codes' }
      }
    end

    def view_header_fields
      {
        stock_adjustment_number: { renderer: :label },
        completed: { renderer: :label, as_boolean: true },
        approved: { renderer: :label, as_boolean: true },
        signed_off: { renderer: :label, as_boolean: true },
        ref_no: { renderer: :label },
        sku_numbers_list: { renderer: :list, items: sku_numbers, caption: 'SKU Numbers' },
        location_list: { renderer: :list, items: locations, caption: 'Location Codes' },
        integration_error: { renderer: :hidden },
        integration_completed: { renderer: :label, as_boolean: true, caption: 'Sent to ERP system' },
        status: { renderer: :label }
      }
    end

    def new_fields
      fields = {
        carton_assembly: { renderer: :hidden },
        staging_consumption: { renderer: :hidden },
        ref_no: { required: true }
      }
      fields[:business_process_id] = if @options[:bsa_type]
                                       { renderer: :hidden }
                                     else
                                       { renderer: :select,
                                         options: @transaction_repo.for_select_bsa_business_processes,
                                         caption: 'Business Process',
                                         required: true }
                                     end
      fields
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_mr_bulk_stock_adjustment(@options[:id])
    end

    def make_new_form_object
      consumption_process_id = @repo.get_id(:business_processes, process: AppConst::PROCESS_CONSUMPTION)
      @form_object = case @options[:bsa_type]
                     when 'consumption'
                       OpenStruct.new(business_process_id: consumption_process_id, ref_no: nil, carton_assembly: false, staging_consumption: true)
                     when 'carton_assembly'
                       OpenStruct.new(business_process_id: consumption_process_id, ref_no: nil, carton_assembly: true, staging_consumption: false)
                     else
                       OpenStruct.new(business_process_id: nil, ref_no: nil, carton_assembly: false, staging_consumption: false)
                     end
    end

    def sku_numbers
      @options[:id] ? @repo.bulk_stock_adjustment_sku_numbers(@options[:id]) : []
    end

    def locations
      @options[:id] ? @repo.bulk_stock_adjustment_locations(@options[:id]) : []
    end

    def business_process
      @repo.find_mr_bulk_stock_adjustment(@options[:id]).business_process
    end

    private

    def add_approve_behaviours
      behaviours do |behaviour|
        behaviour.enable :reject_reason, when: :approve_action, changes_to: ['r']
      end
    end

    def can_approve
      res = @perm.call(:approve, @options[:id], @options[:current_user])
      res.success
    end

    def can_complete
      res = @perm.call(:complete, @options[:id], @options[:current_user])
      res.success
    end

    def can_sign_off
      res = @perm.call(:sign_off, @options[:id], @options[:current_user])
      res.success
    end

    def can_integrate
      res = @perm.call(:integrate, @options[:id], @options[:current_user])
      res.success
    end

    def can_manage_prices
      @transaction_repo.can_manage_bsa_prices?(@options[:id])
    end
  end
end
