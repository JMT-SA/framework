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

    def find_vehicle_jobs(id)
      find_with_association(:vehicle_jobs, id,
                            wrapper: VehicleJob,
                            parent_tables: [
                              { parent_table: :business_processes, foreign_key: :business_process_id, flatten_columns: { process: :process } },
                              { parent_table: :vehicles, foreign_key: :vehicle_id, flatten_columns: { vehicle_code: :vehicle_code } },
                              { parent_table: :locations, foreign_key: :departure_location_id, flatten_columns: { location_long_code: :location_long_code } }
                            ])
    end

    def vehicle_jobs_business_process_id
      DB[:business_processes].where(process: AppConst::PROCESS_VEHICLE_JOBS).get(:id)
    end

    def departure_locations
      loc_type_id = DB[:location_types].where(location_type_code: AppConst::LOCATION_TYPES_BUILDING).get(:id)
      location_repo.for_select_locations(where: { location_type_id: loc_type_id })
    end

    def location_repo
      MasterfilesApp::LocationRepo.new
    end

    def inline_update_vehicle_job_unit(id, attrs)
      update(:vehicle_job_units, id, "#{attrs[:column_name]}": attrs[:column_value])
    end

    def create_vehicle_job_unit(attrs)
      new_attrs = {
        sku_number: sku_number_for_sku_location(attrs[:mr_sku_location_from_id])
      }
      create(:vehicle_job_units, new_attrs.merge(attrs))
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

    def rmd_load_vehicle_unit(attrs) # rubocop:disable Metrics/AbcSize
      unit = DB[:vehicle_job_units].where(vehicle_job_id: attrs[:vehicle_job_id],
                                          location_id: attrs[:location_id],
                                          mr_sku_id: attrs[:mr_sku_id]).first
      return failed_response('Unit does not exist') unless unit

      new_quantity_loaded = (unit[:quantity_loaded] || AppConst::BIG_ZERO) + BigDecimal(attrs[:quantity_to_load])
      exceeded = new_quantity_loaded > unit[:quantity_to_move]
      return failed_response('Can not exceed quantity to move') if exceeded

      vehicle_job = DB[:vehicle_jobs].where(id: attrs[:vehicle_job_id])
      virtual_location_id = vehicle_job.get(:virtual_location_id)
      return failed_response('No virtual location set on Vehicle Job') unless virtual_location_id

      res = PackMaterialApp::MoveMrStock.call(attrs[:mr_sku_id],
                                              virtual_location_id,
                                              BigDecimal(attrs[:quantity_to_load]),
                                              vehicle_job_id: attrs[:vehicle_job_id],
                                              from_location_id: attrs[:location_id],
                                              user_name: @user.user_name,
                                              parent_transaction_id: vehicle_job.get(:load_transaction_id))
      return res unless res.success

      loaded = new_quantity_loaded == unit[:quantity_to_move]
      update(:vehicle_job_units, unit[:id], quantity_loaded: new_quantity_loaded, loaded: loaded)

      update_vehicle_loaded(attrs[:vehicle_job_id])
      success_response('ok', unit)
    end

    def update_vehicle_loaded(vehicle_job_id)
      return nil if exists?(:vehicle_job_units, vehicle_job_id: vehicle_job_id, loaded: false)

      update(:vehicle_jobs, vehicle_job_id, loaded: true)
    end

    # def vehicle_job_confirm_arrival(id)
    # TODO: Confirm arrival && Offload stock to receiving bay
    #   update(:vehicle_jobs, id, arrival_confirmed: true)
    # end

    def vehicle_load_progress_report(vehicle_job_id, sku_id, location_id) # rubocop:disable Metrics/AbcSize
      return nil unless vehicle_job_id && sku_id && location_id

      total_units = DB[:vehicle_job_units].where(vehicle_job_id: vehicle_job_id).all
      sku = DB[:mr_skus].where(id: sku_id)
      {
        tripsheet_number: DB[:vehicle_jobs].where(id: vehicle_job_id).get(:tripsheet_number),
        location_code: replenish_repo.location_long_code_from_location_id(location_id),
        total_units: total_units.count,
        done: total_units.reject { |r| r[:actual_quantity].nil? }.count, # ???
        sku_number: sku.get(:sku_number),
        product_variant_code: DB[:material_resource_product_variants].where(id: sku.get(:mr_product_variant_id)).get(:product_variant_code),
        unit: DB[:vehicle_job_units].where(
          vehicle_job_id: vehicle_job_id,
          mr_sku_id: sku_id,
          location_id: location_id
        ).first
      }
    end

    def replenish_repo
      ReplenishRepo.new
    end
  end
end
