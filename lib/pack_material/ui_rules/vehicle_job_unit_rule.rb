# frozen_string_literal: true

module UiRules
  class VehicleJobUnitRule < Base
    def generate_rules
      @repo = PackMaterialApp::TripsheetsRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if %i[show reopen].include? @mode
      # set_complete_fields if @mode == :complete
      # set_approve_fields if @mode == :approve

      # add_approve_behaviours if @mode == :approve

      form_name 'vehicle_job_unit'
    end

    def set_show_fields
      # mr_sku_location_from_id_label = PackMaterialApp::LocationRepo.new.find_location(@form_object.mr_sku_location_from_id)&.location_long_code
      mr_sku_location_from_id_label = @repo.find(:locations, PackMaterialApp::Location, @form_object.mr_sku_location_from_id)&.location_long_code
      # mr_inventory_transaction_item_id_label = PackMaterialApp::MrInventoryTransactionItemRepo.new.find_mr_inventory_transaction_item(@form_object.mr_inventory_transaction_item_id)&.id
      mr_inventory_transaction_item_id_label = @repo.find(:mr_inventory_transaction_items, PackMaterialApp::MrInventoryTransactionItem, @form_object.mr_inventory_transaction_item_id)&.id
      fields[:mr_sku_location_from_id] = { renderer: :label, with_value: mr_sku_location_from_id_label, caption: 'Mr Sku Location From' }
      fields[:mr_inventory_transaction_item_id] = { renderer: :label, with_value: mr_inventory_transaction_item_id_label, caption: 'Mr Inventory Transaction Item' }
      fields[:vehicle_job_id] = { renderer: :label }
      fields[:quantity_to_move] = { renderer: :label }
      fields[:when_loaded] = { renderer: :label }
      fields[:when_offloaded] = { renderer: :label }
      fields[:when_offloading] = { renderer: :label }
      fields[:quantity_moved] = { renderer: :label }
      fields[:when_loading] = { renderer: :label }
    end

    # def set_approve_fields
    #   set_show_fields
    #   fields[:approve_action] = { renderer: :select, options: [%w[Approve a], %w[Reject r]], required: true }
    #   fields[:reject_reason] = { renderer: :textarea, disabled: true }
    # end

    # def set_complete_fields
    #   set_show_fields
    #   user_repo = DevelopmentApp::UserRepo.new
    #   fields[:to] = { renderer: :select, options: user_repo.email_addresses(user_email_group: AppConst::EMAIL_GROUP_VEHICLE_JOB_UNIT_APPROVERS), caption: 'Email address of person to notify', required: true }
    # end

    def common_fields
      {
        mr_sku_location_from_id: { renderer: :select, options: PackMaterialApp::LocationRepo.new.for_select_locations, disabled_options: PackMaterialApp::LocationRepo.new.for_select_inactive_locations, caption: 'mr_sku_location_from' },
        mr_inventory_transaction_item_id: { renderer: :select, options: PackMaterialApp::MrInventoryTransactionItemRepo.new.for_select_mr_inventory_transaction_items, caption: 'Mr Inventory Transaction Item' },
        vehicle_job_id: {},
        quantity_to_move: {},
        when_loaded: {},
        when_offloaded: {},
        when_offloading: {},
        quantity_moved: {},
        when_loading: {}
      }
    end

    def make_form_object
      if @mode == :new
        make_new_form_object
        return
      end

      @form_object = @repo.find_vehicle_job_unit(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(mr_sku_location_from_id: nil,
                                    mr_inventory_transaction_item_id: nil,
                                    vehicle_job_id: nil,
                                    quantity_to_move: nil,
                                    when_loaded: nil,
                                    when_offloaded: nil,
                                    when_offloading: nil,
                                    quantity_moved: nil,
                                    when_loading: nil)
    end

    # private

    # def add_approve_behaviours
    #   behaviours do |behaviour|
    #     behaviour.enable :reject_reason, when: :approve_action, changes_to: ['r']
    #   end
    # end
  end
end
