# frozen_string_literal: true

module UiRules
  class MrBulkStockAdjustmentRule < Base
    def generate_rules
      @repo = PackMaterialApp::TransactionsRepo.new
      @stock_repo = PackMaterialApp::MrStockRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields case @mode
                               when :new
                                 new_fields
                               when :edit_header
                                 header_fields
                               else
                                 edit_fields
                               end

      set_show_fields if %i[show reopen].include? @mode
      set_complete_fields if @mode == :complete
      set_approve_fields if @mode == :approve

      add_approve_behaviours if @mode == :approve

      form_name 'mr_bulk_stock_adjustment'
    end

    def set_show_fields
      fields[:stock_adjustment_number] = { renderer: :label }
      fields[:sku_numbers] = { renderer: :label }
      fields[:location_ids] = { renderer: :label }
      fields[:active] = { renderer: :label, as_boolean: true }
      fields[:is_stock_take] = { renderer: :label, as_boolean: true }
      fields[:completed] = { renderer: :label }
      fields[:approved] = { renderer: :label, as_boolean: true }
    end

    def set_approve_fields
      set_show_fields
      fields[:approve_action] = { renderer: :select, options: [%w[Approve a], %w[Reject r]], required: true }
      fields[:reject_reason] = { renderer: :textarea, disabled: true }
    end

    def set_complete_fields
      set_show_fields
      user_repo = DevelopmentApp::UserRepo.new
      fields[:to] = { renderer: :select, options: user_repo.email_addresses(user_email_group: AppConst::EMAIL_GROUP_MR_BULK_STOCK_ADJUSTMENT_APPROVERS), caption: 'Email address of person to notify', required: true }
    end

    def edit_fields
      {
        stock_adjustment_number: { renderer: :label },
        is_stock_take: { renderer: :label, as_boolean: true }
      }
    end

    def header_fields
      {
        mr_inventory_transaction_id: { renderer: :label, caption: 'Inventory Transaction' },
        stock_adjustment_number: { renderer: :label },
        is_stock_take: { renderer: :checkbox },
        completed: { renderer: :hidden },
        approved: { renderer: :hidden },
        business_process_id: { renderer: :select, options: @stock_repo.for_select_business_processes, caption: 'Business Process', required: true },
        ref_no: { required: true },
        sku_numbers_list: { renderer: :list, items: @object.sku_numbers, caption: 'SKU Numbers' },
        location_list: { renderer: :list, items: @repo.location_codes_list(Array(@object.location_ids)), caption: 'Location Codes' }
      }
    end

    def new_fields
      {
        is_stock_take: { renderer: :checkbox },
        business_process_id: { renderer: :select, options: @stock_repo.for_select_business_processes, caption: 'Business Process', required: true },
        ref_no: { required: true }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @object = @form_object = @repo.find_mr_bulk_stock_adjustment(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(sku_numbers: nil,
                                    location_codes: nil,
                                    is_stock_take: nil,
                                    business_process_id: nil,
                                    ref_no: nil)
    end

    private

    def add_approve_behaviours
      behaviours do |behaviour|
        behaviour.enable :reject_reason, when: :approve_action, changes_to: ['r']
      end
    end
  end
end
