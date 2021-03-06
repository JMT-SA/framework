# frozen_string_literal: true

module PackMaterialApp
  class TripsheetsRepo < BaseRepo # rubocop:disable Metrics/ClassLength
    build_for_select :vehicle_types,
                     label: :type_code,
                     value: :id,
                     no_active_check: true,
                     order_by: :type_code

    crud_calls_for :vehicle_types, name: :vehicle_type, wrapper: VehicleType

    build_for_select :vehicles,
                     label: :vehicle_code,
                     value: :id,
                     no_active_check: true,
                     order_by: :vehicle_code

    crud_calls_for :vehicles, name: :vehicle, wrapper: Vehicle

    build_for_select :vehicle_jobs,
                     label: :tripsheet_number,
                     value: :id,
                     no_active_check: true,
                     order_by: :tripsheet_number

    crud_calls_for :vehicle_jobs, name: :vehicle_job, wrapper: VehicleJob

    build_for_select :vehicle_job_units,
                     label: :id,
                     value: :id,
                     no_active_check: true,
                     order_by: :id

    crud_calls_for :vehicle_job_units, name: :vehicle_job_unit, wrapper: VehicleJobUnit

    def find_vehicle(id)
      find_with_association(:vehicles, id,
                            wrapper: Vehicle,
                            parent_tables: [{ parent_table: :vehicle_types,
                                              foreign_key: :vehicle_type_id,
                                              flatten_columns: { type_code: :type_code } }])
    end

    def find_vehicle_job(id)
      find_with_association(:vehicle_jobs, id,
                            wrapper: VehicleJob,
                            lookup_functions: [{ function: :fn_current_status,
                                                 args: ['vehicle_jobs', :id],
                                                 col_name: :status }],
                            parent_tables: [
                              { parent_table: :business_processes, foreign_key: :business_process_id, flatten_columns: { process: :process } },
                              { parent_table: :vehicles, foreign_key: :vehicle_id, flatten_columns: { vehicle_code: :vehicle_code } },
                              { parent_table: :locations, foreign_key: :departure_location_id, flatten_columns: { location_long_code: :departure_location_long_code } },
                              { parent_table: :locations, foreign_key: :virtual_location_id, flatten_columns: { location_long_code: :virtual_location_long_code } },
                              { parent_table: :locations, foreign_key: :planned_location_id, flatten_columns: { location_long_code: :planned_location_long_code } }
                            ])
    end

    def find_vehicle_job_unit(id)
      find_with_association(:vehicle_job_units, id,
                            wrapper: VehicleJobUnit,
                            lookup_functions: [{ function: :fn_current_status,
                                                 args: ['vehicle_job_units', :id],
                                                 col_name: :status }],
                            parent_tables: [
                              { parent_table: :vehicle_jobs, foreign_key: :vehicle_job_id, flatten_columns: { tripsheet_number: :tripsheet_number } },
                              { parent_table: :locations, foreign_key: :location_id, flatten_columns: { location_short_code: :from_location_short_code } }
                            ])
    end

    def update_planned_location(id, attrs)
      update(:vehicle_jobs, id, planned_location_id: attrs[:planned_location_id])
    end

    def confirm_arrival_vehicle_job(id)
      update(:vehicle_jobs, id, arrival_confirmed: true)
    end

    def vehicle_job_total_offload_stock(id)
      all_hash(:vehicle_job_units, vehicle_job_id: id)
    end

    def vehicle_jobs_business_process_id
      DB[:business_processes].where(process: AppConst::PROCESS_VEHICLE_JOBS).get(:id)
    end

    def departure_locations
      loc_type_id = DB[:location_types].where(location_type_code: AppConst::LOCATION_TYPES_BUILDING).get(:id)
      location_repo.for_select_locations(where: { location_type_id: loc_type_id, restricted: false })
    end

    def location_repo
      MasterfilesApp::LocationRepo.new
    end

    def inline_update_vehicle_job_unit(id, attrs)
      update(:vehicle_job_units, id, "#{attrs[:column_name]}": attrs[:column_value])
    end

    def create_vehicle_job_unit(attrs)
      message = nil
      message = 'Quantity to move must be less than or equal to available quantity' unless attrs[:quantity_to_move] <= attrs[:available_quantity]
      return validation_failed_response(OpenStruct.new(messages: { base: [message] })) if message

      new_attrs = {
        sku_number: DB[:mr_skus].where(
          id: attrs[:mr_sku_id]
        ).get(:sku_number)
      }
      new_attrs = new_attrs.merge(attrs.to_h)
      new_attrs.delete(:available_quantity)

      unit_id = create(:vehicle_job_units, new_attrs)
      success_response('Tripsheet Item created successfully', unit_id)
    end

    def link_mr_skus(vehicle_job_id, mr_sku_ids)
      DB[:vehicle_jobs_sku_numbers].where(vehicle_job_id: vehicle_job_id).delete
      mr_sku_ids.each do |mr_sku_id|
        DB[:vehicle_jobs_sku_numbers].insert(vehicle_job_id: vehicle_job_id, mr_sku_id: mr_sku_id)
      end
    end

    def link_locations(vehicle_job_id, location_ids)
      DB[:vehicle_jobs_locations].where(vehicle_job_id: vehicle_job_id).delete
      location_ids.each do |location_id|
        DB[:vehicle_jobs_locations].insert(vehicle_job_id: vehicle_job_id, location_id: location_id)
      end
    end

    def get_sku_location_info_ids(sku_location_id)
      sku_location = DB[:mr_sku_locations].where(id: sku_location_id)
      {
        sku_number: sku_number_for_sku_location(sku_location_id),
        available_quantity: sku_location.get(:quantity),
        sku_id: sku_location.get(:mr_sku_id),
        location_code: DB[:locations].where(
          id: sku_location.get(:location_id)
        ).map { |r| [r[:location_long_code], r[:id]] },
        location_id: sku_location.get(:location_id),
        mr_sku_location_id: sku_location_id
      }
    end

    def sku_number_for_sku_location(sku_location_id)
      DB[:mr_skus].where(id: DB[:mr_sku_locations].where(id: sku_location_id).get(:mr_sku_id)).get(:sku_number)
    end

    def vehicle_job_sku_numbers(vehicle_job_id)
      DB[:mr_skus].where(
        id: vehicle_job_sku_ids(vehicle_job_id)
      ).map { |r| ["#{r[:sku_number]}: #{product_code(r[:mr_product_variant_id])}", r[:id]] }
    end

    def product_code(product_variant_id)
      DB[:material_resource_product_variants].where(id: product_variant_id).get(:product_variant_code)
    end

    def vehicle_job_locations(vehicle_job_id)
      DB[:locations].where(
        id: vehicle_job_location_ids(vehicle_job_id)
      ).map { |r| [r[:location_long_code], r[:id]] }
    end

    def vehicle_job_location_ids(vehicle_job_id)
      DB[:vehicle_jobs_locations].where(
        vehicle_job_id: vehicle_job_id
      ).select_map(:location_id)
    end

    def vehicle_job_sku_ids(vehicle_job_id)
      DB[:vehicle_jobs_sku_numbers].where(
        vehicle_job_id: vehicle_job_id
      ).select_map(:mr_sku_id)
    end

    def load_vehicle_job(id)
      update(:vehicle_jobs, id, loaded: true)
    end

    def vehicle_job_id_from_number(tripsheet_number)
      DB[:vehicle_jobs].where(tripsheet_number: tripsheet_number).get(:id)
    end

    def rmd_load_vehicle_unit(mr_sku_id, quantity_to_load, location_id, vehicle_job_id, force_load) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      return failed_response('Invalid location, should be within same building') unless validate_location(vehicle_job_id, location_id, false)

      unit = DB[:vehicle_job_units].where(vehicle_job_id: vehicle_job_id,
                                          location_id: location_id,
                                          mr_sku_id: mr_sku_id).first
      return failed_response('Unit does not exist') unless unit
      return failed_response('Unit is already loaded') if unit[:loaded]

      new_quantity_loaded = (unit[:quantity_loaded] || AppConst::BIG_ZERO) + BigDecimal(quantity_to_load)
      return failed_response('Can not exceed quantity to move') if new_quantity_loaded > unit[:quantity_to_move]

      vehicle_job = DB[:vehicle_jobs].where(id: vehicle_job_id)
      return failed_response('No virtual location set on Tripsheet') unless vehicle_job.get(:virtual_location_id)

      loaded = new_quantity_loaded == unit[:quantity_to_move]
      loaded_at = Time.now
      update(:vehicle_job_units,
             unit[:id],
             quantity_loaded: new_quantity_loaded,
             loaded: force_load || loaded,
             when_loaded: loaded ? loaded_at : nil,
             when_loading: loaded_at)
      update_vehicle_loaded(vehicle_job_id, loaded_at)

      unit = DB[:vehicle_job_units].where(id: unit[:id]).first
      success_response('ok', unit: unit, vehicle_job: vehicle_job.first)
    end

    def update_vehicle_loaded(vehicle_job_id, loaded_at)
      return nil if exists?(:vehicle_job_units, vehicle_job_id: vehicle_job_id, loaded: false)

      update(:vehicle_jobs, vehicle_job_id, loaded: true, when_loading: loaded_at, when_loaded: loaded_at)
    end

    def rmd_offload_vehicle_unit(mr_sku_id, qty_to_offload, location_id, vehicle_job_id) # rubocop:disable Metrics/AbcSize
      valid_location = validate_location(vehicle_job_id, location_id, false)
      return failed_response('Invalid location, should be within same building') unless valid_location

      units = DB[:vehicle_job_units].where(vehicle_job_id: vehicle_job_id, mr_sku_id: mr_sku_id)
      return failed_response('No units for SKU') if units.all.none?

      available_units = units.where(offloaded: false).all
      return failed_response('Units for SKU are already offloaded') if available_units.none?

      total_cap = units.map { |r| r[:quantity_loaded].to_f - r[:quantity_offloaded].to_f }.sum
      return failed_response('Can not offload more than was loaded') if qty_to_offload > total_cap

      offloaded_at = Time.now
      vehicle_job_units_for_sku_offload(units, qty_to_offload, offloaded_at)
      res = update_vehicle_offloaded(vehicle_job_id, offloaded_at)
      res_message = res.success ? 'Vehicle fully offloaded' : 'Vehicle not yet fully offloaded'
      success_response(res_message, units: units.all, vehicle_job: res.instance)
    end

    def vehicle_job_units_for_sku_offload(units, qty_to_offload, offloaded_at) # rubocop:disable Metrics/AbcSize
      offloaded_amt = 0
      units.where(offloaded: false).order_by(:quantity_loaded).all.each do |unit_hash|
        unit = DB[:vehicle_job_units].where(id: unit_hash[:id])

        amt_to_offload = qty_to_offload - offloaded_amt # Amount left to offload
        capacity = unit.get(:quantity_loaded).to_f - unit.get(:quantity_offloaded).to_f # how much we can offload

        rest = amt_to_offload - capacity
        offload_amt = rest.positive? ? capacity : amt_to_offload # Amount we can offload at this unit
        offloaded_amt += offload_amt # Add to total offloaded amt
        offloaded = offload_amt == capacity # Has unit been fully offloaded
        new_quantity_offloaded = offload_amt + unit.get(:quantity_offloaded).to_f
        unit.update(quantity_offloaded: new_quantity_offloaded,
                    offloaded: offloaded,
                    when_offloaded: offloaded ? offloaded_at : nil,
                    when_offloading: offloaded_at)
      end
    end

    def full_offload_vehicle_units(vehicle_job_id) # rubocop:disable Metrics/AbcSize
      units = DB[:vehicle_job_units].where(vehicle_job_id: vehicle_job_id).all
      return failed_response('No Tripsheet Items') if units.none?

      vehicle_job = DB[:vehicle_jobs].where(id: vehicle_job_id)
      return failed_response('No planned receiving bay location set on Tripsheet') unless vehicle_job.get(:planned_location_id)

      now = Time.now
      units.each do |unit|
        update(:vehicle_job_units,
               unit[:id],
               quantity_offloaded: unit[:quantity_loaded],
               offloaded: true,
               when_offloaded: now,
               when_offloading: now)
      end
      vehicle_job.update(offloaded: true, when_offloaded: now, when_offloading: now)
      success_response('ok', units: units, vehicle_job: vehicle_job.first)
    end

    def update_vehicle_offloaded(vehicle_job_id, offloaded_at)
      vehicle_job = DB[:vehicle_jobs].where(id: vehicle_job_id)
      has_open_units = exists?(:vehicle_job_units, vehicle_job_id: vehicle_job_id, offloaded: false)
      return failed_response('Vehicle Job is not fully offloaded yet', vehicle_job.first) if has_open_units

      vehicle_job.update(offloaded: true, when_offloaded: offloaded_at, when_offloading: offloaded_at)
      success_response('ok', vehicle_job.first)
    end

    def load_progress_report(vehicle_job_id, sku_id, from_loc_id) # rubocop:disable Metrics/AbcSize
      return nil unless vehicle_job_id && sku_id && from_loc_id

      total_units = DB[:vehicle_job_units].where(vehicle_job_id: vehicle_job_id).all
      sku = DB[:mr_skus].where(id: sku_id)
      unit = DB[:vehicle_job_units].where(vehicle_job_id: vehicle_job_id, mr_sku_id: sku_id, location_id: from_loc_id).first
      {
        tripsheet_number: DB[:vehicle_jobs].where(id: vehicle_job_id).get(:tripsheet_number),
        done_loading: total_units.select { |r| r[:loaded] }.count,
        total_units: total_units.count,
        location_code: replenish_repo.location_long_code_from_location_id(from_loc_id),
        sku_number: sku.get(:sku_number),
        product_variant_code: DB[:material_resource_product_variants].where(id: sku.get(:mr_product_variant_id)).get(:product_variant_code),
        quantity_to_move: unit[:quantity_to_move],
        quantity_loaded: unit[:quantity_loaded]
      }
    end

    def offload_progress_report(vehicle_job_id, to_location_id, sku_id) # rubocop:disable Metrics/AbcSize
      return nil unless vehicle_job_id && to_location_id && sku_id

      total_units = DB[:vehicle_job_units].where(vehicle_job_id: vehicle_job_id).all
      sku = DB[:mr_skus].where(id: sku_id)
      offload_units = DB[:vehicle_job_units].where(vehicle_job_id: vehicle_job_id, mr_sku_id: sku_id)
      {
        tripsheet_number: DB[:vehicle_jobs].where(id: vehicle_job_id).get(:tripsheet_number),
        done_offloading: total_units.select { |r| r[:offloaded] }.count,
        total_units: total_units.count,
        location_code: replenish_repo.location_long_code_from_location_id(to_location_id),
        sku_number: sku.get(:sku_number),
        product_variant_code: DB[:material_resource_product_variants].where(id: sku.get(:mr_product_variant_id)).get(:product_variant_code),
        quantity_to_offload: offload_units.map { |r| r[:quantity_loaded] }.sum,
        quantity_offloaded: offload_units.map { |r| r[:quantity_offloaded] }.sum
      }
    end

    def replenish_repo
      ReplenishRepo.new
    end

    def find_parent_building(location_id)
      location_repo = MasterfilesApp::LocationRepo.new
      res = location_repo.find_parent_of_type(AppConst::LOCATION_TYPES_BUILDING, location_id)
      res.success ? res.instance : nil
    end

    # @return [TrueClass] true || false
    def validate_location(vehicle_job_id, location_id, load = true)
      vehicle_job = find_hash(:vehicle_jobs, vehicle_job_id)
      parent_location_id = find_parent_building(location_id)
      if load
        parent_location_id == find_parent_building(vehicle_job[:departure_location_id])
      elsif (planned_loc_id = vehicle_job[:planned_location_id])
        parent_location_id == find_parent_building(planned_loc_id)
      else
        true
      end
    end
  end
end
