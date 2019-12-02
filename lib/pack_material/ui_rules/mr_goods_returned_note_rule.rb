# frozen_string_literal: true

module UiRules
  class MrGoodsReturnedNoteRule < Base
    def generate_rules # rubocop:disable Metrics/AbcSize
      @repo = PackMaterialApp::DispatchRepo.new
      @replenish_repo = PackMaterialApp::ReplenishRepo.new
      @perm = PackMaterialApp::TaskPermissionCheck::MrGoodsReturnedNote
      make_form_object
      apply_form_values
      set_rules if @mode == :edit

      common_values_for_fields case @mode
                               when :new
                                 new_fields
                               else
                                 rules[:shipped] ? common_fields.merge(show_fields) : common_fields.merge(edit_fields)
                               end

      form_name 'mr_goods_returned_note'
    end

    def set_rules
      rules[:shipped] = @form_object.shipped
      rules[:can_ship] = can_ship
      rules[:can_complete_invoice] = can_complete_invoice
    end

    def new_fields
      {
        mr_delivery_id: { renderer: :select, options: @replenish_repo.for_select_mr_deliveries(where: { invoice_completed: true }), caption: 'Please select Delivery', required: true }
      }
    end

    def edit_fields
      {
        dispatch_location_id: { renderer: :select, options: @repo.dispatch_locations, selected: @form_object.dispatch_location_id, readonly: @form_object.shipped },
        remarks: { renderer: :textarea, rows: 5 },
        credit_note_number: { renderer: :hidden }
      }
    end

    def show_fields
      dispatch_loc = @replenish_repo.location_long_code_from_location_id(@form_object.dispatch_location_id)
      {
        dispatch_location_id: { renderer: :label, with_value: dispatch_loc },
        credit_note_number: { renderer: :label },
        remarks: { renderer: :label }
      }
    end

    def common_fields
      {
        mr_delivery_id: { renderer: :hidden },
        issue_transaction_id: { renderer: :hidden },
        created_by: { renderer: :label },
        delivery_number: { renderer: :label, with_value: delivery_number }
      }
    end

    def make_form_object
      @form_object = if @mode == :new
                       OpenStruct.new(mr_delivery_id: nil)
                     else
                       @repo.find_mr_goods_returned_note(@options[:id])
                     end
    end

    private

    def delivery_number
      @replenish_repo.delivery_number_from_id(@form_object.mr_delivery_id)
    end

    def can_ship
      interactor.check_permission(:can_ship, @options[:id]).success
    end

    def can_complete_invoice
      interactor.check_permission(:complete_invoice, @options[:id]).success
    end

    def interactor
      @interactor ||= @options[:interactor]
    end
  end
end
