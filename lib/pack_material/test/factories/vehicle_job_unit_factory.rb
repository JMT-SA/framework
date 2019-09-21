# frozen_string_literal: true

# ========================================================= #
# NB. Scaffolds for test factories should be combined       #
#     - Otherwise you'll have methods for the same table in #
#       several factories.                                  #
#     - Rather create a factory for several related tables  #
# ========================================================= #

module PackMaterialApp
  module VehicleJobUnitFactory
    def create_vehicle_job_unit(opts = {})
      location_id = create_location
      mr_inventory_transaction_item_id = create_mr_inventory_transaction_item

      default = {
        mr_sku_location_from_id: location_id,
        mr_inventory_transaction_item_id: mr_inventory_transaction_item_id,
        vehicle_job_id: Faker::Number.number,
        quantity_to_move: Faker::Number.decimal,
        when_loaded: '2010-01-01 12:00',
        when_offloaded: '2010-01-01 12:00',
        when_offloading: '2010-01-01 12:00',
        quantity_loaded: Faker::Number.decimal,
        quantity_offloaded: Faker::Number.decimal,
        created_at: '2010-01-01 12:00',
        updated_at: '2010-01-01 12:00',
        mr_sku_id: Faker::Number.number,
        sku_number: Faker::Number.number,
        location_id: Faker::Number.number,
        when_loading: '2010-01-01 12:00'
      }
      DB[:vehicle_job_units].insert(default.merge(opts))
    end

    def create_location(opts = {})
      location_storage_type_id = create_location_storage_type
      location_type_id = create_location_type
      location_assignment_id = create_location_assignment
      location_storage_definition_id = create_location_storage_definition

      default = {
        primary_storage_type_id: location_storage_type_id,
        location_type_id: location_type_id,
        primary_assignment_id: location_assignment_id,
        location_long_code: Faker::Lorem.word,
        location_description: Faker::Lorem.word,
        active: true,
        has_single_container: false,
        virtual_location: false,
        consumption_area: false,
        created_at: '2010-01-01 12:00',
        updated_at: '2010-01-01 12:00',
        location_short_code: Faker::Lorem.word,
        can_be_moved: false,
        print_code: Faker::Lorem.word,
        location_storage_definition_id: location_storage_definition_id,
        can_store_stock: false
      }
      DB[:locations].insert(default.merge(opts))
    end

    def create_location_storage_type(opts = {})
      default = {
        storage_type_code: Faker::Lorem.word,
        created_at: '2010-01-01 12:00',
        updated_at: '2010-01-01 12:00',
        location_short_code_prefix: Faker::Lorem.word
      }
      DB[:location_storage_types].insert(default.merge(opts))
    end

    def create_location_type(opts = {})
      default = {
        location_type_code: Faker::Lorem.word,
        short_code: Faker::Lorem.word,
        created_at: '2010-01-01 12:00',
        updated_at: '2010-01-01 12:00',
        can_be_moved: false
      }
      DB[:location_types].insert(default.merge(opts))
    end

    def create_location_assignment(opts = {})
      default = {
        assignment_code: Faker::Lorem.word,
        created_at: '2010-01-01 12:00',
        updated_at: '2010-01-01 12:00'
      }
      DB[:location_assignments].insert(default.merge(opts))
    end

    def create_location_storage_definition(opts = {})
      default = {
        storage_definition_code: Faker::Lorem.word,
        active: true,
        created_at: '2010-01-01 12:00',
        updated_at: '2010-01-01 12:00',
        storage_definition_format: Faker::Lorem.word,
        storage_definition_description: Faker::Lorem.word
      }
      DB[:location_storage_definitions].insert(default.merge(opts))
    end

    def create_mr_inventory_transaction_item(opts = {})
      default = {
        mr_sku_id: Faker::Number.number,
        inventory_uom_id: Faker::Number.number,
        from_location_id: Faker::Number.number,
        mr_inventory_transaction_id: Faker::Number.number,
        quantity: Faker::Number.decimal,
        to_location_id: Faker::Number.number
      }
      DB[:mr_inventory_transaction_items].insert(default.merge(opts))
    end
  end
end
