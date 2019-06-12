# frozen_string_literal: true

module UiRules
  class MrBulkStockAdjustmentRule < Base
    def generate_rules
      @repo       = PackMaterialApp::TransactionsRepo.new
      @stock_repo = PackMaterialApp::MrStockRepo.new
      @perm       = PackMaterialApp::TaskPermissionCheck::MrBulkStockAdjustment
      make_form_object
      apply_form_values

      if @mode == :edit
        rules[:can_sign_off] = can_sign_off
        rules[:can_complete] = can_complete
        rules[:can_approve]  = can_approve
        rules[:show_only]    = @form_object.completed || @form_object.approved
      end

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

    def show_fields
      {
        stock_adjustment_number: { renderer: :label },
        ref_no:                  { renderer: :label },
        is_stock_take:           { renderer: :label, as_boolean: true },
        completed:               { renderer: :label, as_boolean: true },
        approved:                { renderer: :label, as_boolean: true },
        signed_off:              { renderer: :label, as_boolean: true },
      }
    end

    def edit_fields
      {
        stock_adjustment_number: { renderer: :label },
        ref_no:                  { renderer: :label },
        is_stock_take:           { renderer: :label, as_boolean: true },
        completed:               { renderer: :label, as_boolean: true },
        approved:                { renderer: :label, as_boolean: true },
        signed_off:              { renderer: :label, as_boolean: true },
      }
    end

    def header_fields
      {
        create_transaction_id:   { renderer: :label, caption: 'Create Transaction' },
        destroy_transaction_id:  { renderer: :label, caption: 'Destroy Transaction' },
        stock_adjustment_number: { renderer: :label },
        is_stock_take:           { renderer: :checkbox },
        completed:               { renderer: :hidden },
        approved:                { renderer: :hidden },
        signed_off:              { renderer: :hidden },
        business_process_id:     { renderer: :select, options: @stock_repo.for_select_business_processes, caption: 'Business Process', required: true },
        ref_no:                  { required: true },
        sku_numbers_list:        { renderer: :list, items: sku_numbers, caption: 'SKU Numbers' },
        location_list:           { renderer: :list, items: locations, caption: 'Location Codes' }
      }
    end

    def view_header_fields
      {
        stock_adjustment_number: { renderer: :label },
        is_stock_take:           { renderer: :label, as_boolean: true },
        completed:               { renderer: :label, as_boolean: true },
        approved:                { renderer: :label, as_boolean: true },
        signed_off:              { renderer: :label, as_boolean: true },
        ref_no:                  { renderer: :label },
        sku_numbers_list:        { renderer: :list, items: sku_numbers, caption: 'SKU Numbers' },
        location_list:           { renderer: :list, items: locations, caption: 'Location Codes' }
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

      @form_object = @repo.find_mr_bulk_stock_adjustment(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(is_stock_take: nil,
                                    business_process_id: nil,
                                    ref_no: nil)
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
  end
end
