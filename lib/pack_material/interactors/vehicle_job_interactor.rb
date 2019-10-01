# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength

module PackMaterialApp
  class VehicleJobInteractor < BaseInteractor
    def create_vehicle_job(params) # rubocop:disable Metrics/AbcSize
      res = validate_vehicle_job_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      id = nil
      repo.transaction do
        id = repo.create_vehicle_job(res)
        log_status('vehicle_jobs', id, 'CREATED')
        log_transaction
      end
      instance = vehicle_job(id)
      success_response("Created vehicle job #{instance.tripsheet_number}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { tripsheet_number: ['This vehicle job already exists'] }))
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def update_vehicle_job(id, params)
      res = validate_update_vehicle_job_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      repo.transaction do
        repo.update_vehicle_job(id, res)
        log_transaction
      end
      instance = vehicle_job(id)
      success_response("Updated vehicle job #{instance.tripsheet_number}", instance)
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def load_vehicle_job(id)
      assert_permission!(:can_load, id)
      repo.transaction do
        log_transaction

        log_status('vehicle_jobs', id, 'LOADED')
        repo.load_vehicle_job(id)

        instance = vehicle_job(id)
        success_response('Loaded Vehicle Job', instance)
      end
    rescue Crossbeams::TaskNotPermittedError => e
      failed_response(e.message)
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def vehicle_job_confirm_arrival(id)
      assert_permission!(:confirm_arrival, id)
      repo.transaction do
        log_transaction
        offload_to_assigned_receiving_bay(id)
        repo.confirm_arrival_vehicle_job(id)
        log_status('vehicle_jobs', id, 'ARRIVAL CONFIRMED')

        instance = vehicle_job(id)
        success_response('Vehicle Job Arrival Confirmed', instance)
      end
    rescue Crossbeams::TaskNotPermittedError => e
      failed_response(e.message)
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def offload_to_assigned_receiving_bay(id)
      vehicle_job = vehicle_job(id)
      offload_stock = repo.vehicle_job_total_offload_stock(id)
      offload_stock.each do |stock_unit|
        res = PackMaterialApp::MoveMrStock.call(stock_unit[:mr_sku_id],
                                                vehicle_job[:planned_location_id],
                                                stock_unit[:quantity_loaded],
                                                from_location_id: vehicle_job[:virtual_location_id],
                                                user_name: @user.user_name,
                                                vehicle_job_id: id,
                                                parent_transaction_id: vehicle_job[:offload_transaction_id],
                                                transaction_type: 'offload')
        raise Crossbeams::InfoError, res.message unless res.success
      end
    end

    def delete_vehicle_job(id)
      name = vehicle_job(id).tripsheet_number
      repo.transaction do
        repo.delete_vehicle_job(id)
        log_status('vehicle_jobs', id, 'DELETED')
        log_transaction
      end
      success_response("Deleted vehicle job #{name}")
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def link_mr_skus(id, mr_sku_ids)
      repo.transaction do
        repo.link_mr_skus(id, mr_sku_ids)
      end
      success_response('SKUs linked successfully', has_skus: mr_sku_ids.any?)
    end

    def link_locations(id, location_ids)
      repo.transaction do
        repo.link_locations(id, location_ids)
      end
      success_response('Locations linked successfully', has_locations: location_ids.any?)
    end

    def get_sku_location_info_ids(sku_location_id)
      repo.get_sku_location_info_ids(sku_location_id)
    end

    def load_vehicle_unit(params) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
      res = prepare_for_loading(params)
      return res unless res.success

      attrs = res.instance
      job_id = attrs[:vehicle_job_id]
      assert_permission!(:can_load, job_id)
      repo.transaction do
        log_transaction
        res = repo.rmd_load_vehicle_unit(attrs[:sku_id], attrs[:qty], attrs[:location_id], job_id)
        raise Crossbeams::InfoError, res.message unless res.success

        unit = res.instance[:unit]
        vehicle_job = res.instance[:vehicle_job]
        res = PackMaterialApp::MoveMrStock.call(attrs[:sku_id],
                                                vehicle_job[:virtual_location_id],
                                                attrs[:qty],
                                                from_location_id: attrs[:location_id],
                                                user_name: @user.user_name,
                                                vehicle_job_id: job_id,
                                                parent_transaction_id: vehicle_job[:load_transaction_id],
                                                transaction_type: 'load')
        raise Crossbeams::InfoError, res.message unless res.success

        log_status('vehicle_job_units', unit[:id], unit[:loaded] ? 'LOADED' : 'LOADING')
        log_status('vehicle_jobs', job_id, vehicle_job[:loaded] ? 'LOADED' : 'LOADING')
        html_report = html_vehicle_load_progress_report(job_id, attrs[:sku_id], attrs[:location_id])
        success_response('Successful vehicle unit load', OpenStruct.new(vehicle_job_id: job_id, report: html_report))
      end
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    rescue Crossbeams::TaskNotPermittedError => e
      failed_response(e.message)
    end

    def offload_vehicle_unit(params) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
      res = prepare_for_loading(params)
      return res unless res.success

      attrs = res.instance
      job_id = attrs[:vehicle_job_id]
      assert_permission!(:can_offload, job_id)
      repo.transaction do
        log_transaction
        res = repo.rmd_offload_vehicle_unit(attrs[:sku_id], attrs[:qty], attrs[:location_id], job_id)
        raise Crossbeams::InfoError, res.message unless res.success

        unit = res.instance[:unit]
        vehicle_job = res.instance[:vehicle_job]
        res = PackMaterialApp::MoveMrStock.call(attrs[:sku_id],
                                                attrs[:location_id],
                                                attrs[:qty],
                                                from_location_id: vehicle_job[:virtual_location_id],
                                                user_name: @user.user_name,
                                                vehicle_job_id: job_id,
                                                parent_transaction_id: vehicle_job[:offload_transaction_id],
                                                transaction_type: 'offload')
        raise Crossbeams::InfoError, res.message unless res.success

        log_status('vehicle_job_units', unit[:id], unit[:offloaded] ? 'OFFLOADED' : 'OFFLOADING')
        log_status('vehicle_jobs', job_id, vehicle_job[:offloaded] ? 'OFFLOADED' : 'OFFLOADING')
        html_report = html_vehicle_offload_progress_report(job_id, attrs[:sku_id], attrs[:location_id])
        success_response('Successful vehicle unit offload', OpenStruct.new(vehicle_job_id: job_id, report: html_report))
      end
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    rescue Crossbeams::TaskNotPermittedError => e
      failed_response(e.message)
    end

    def prepare_for_loading(params) # rubocop:disable Metrics/AbcSize
      vehicle_job_id = repo.vehicle_job_id_from_number(params[:tripsheet_number])
      sku_ids = replenish_repo.sku_ids_from_numbers(params[:sku_number])
      res = validate_loading_vehicle_unit_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      location_id = replenish_repo.resolve_location_id_from_scan(params[:location], params[:location_scan_field])
      return failed_response('Location not found, please use location short code') unless location_id

      success_response('ok',
                       sku_id: sku_ids[0],
                       qty: BigDecimal(params[:quantity]),
                       location_id: Integer(location_id),
                       vehicle_job_id: vehicle_job_id)
    end

    def update_planned_location(id, params)
      res = validate_update_planned_loc_vehicle_job_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      repo.update_planned_location(id, res)
      success_response('ok')
    end

    def assert_permission!(task, id = nil)
      res = check_permission(task, id)
      raise Crossbeams::TaskNotPermittedError, res.message unless res.success
    end

    def check_permission(task, id = nil)
      TaskPermissionCheck::VehicleJob.call(task, id, @user)
    end

    private

    def repo
      @repo ||= TripsheetsRepo.new
    end

    def replenish_repo
      @replenish_repo ||= ReplenishRepo.new
    end

    def vehicle_job(id)
      repo.find_vehicle_job(id)
    end

    def validate_vehicle_job_params(params)
      NewVehicleJobSchema.call(params)
    end

    def validate_update_vehicle_job_params(params)
      EditVehicleJobSchema.call(params)
    end

    def validate_update_planned_loc_vehicle_job_params(params)
      UpdateVehicleJobSchema.call(params)
    end

    def validate_loading_vehicle_unit_params(params)
      VehicleJobUnitLoadingSchema.call(params)
    end

    def html_vehicle_load_progress_report(vehicle_job_id, sku_id, location_id)
      inst = repo.vehicle_load_progress_report(vehicle_job_id, sku_id, location_id)
      <<~HTML
        Tripsheet (#{inst[:tripsheet_number]}): #{inst[:done_loading]} of #{inst[:total_units]} units.<br>
        Last scan:<br>
        LOC: #{inst[:location_code]}<br>
        SKU (#{inst[:sku_number]}): #{inst[:product_variant_code]}<br>
        Qty To Move: #{UtilityFunctions.delimited_number(inst[:unit][:quantity_to_move])}<br>
        Qty Loaded: #{UtilityFunctions.delimited_number(inst[:unit][:quantity_loaded])}<br>
      HTML
    end

    def html_vehicle_offload_progress_report(vehicle_job_id, sku_id, location_id)
      inst = repo.vehicle_load_progress_report(vehicle_job_id, sku_id, location_id)
      <<~HTML
        Tripsheet (#{inst[:tripsheet_number]}): #{inst[:done_offloading]} of #{inst[:total_units]} units.<br>
        Last scan:<br>
        LOC: #{inst[:location_code]}<br>
        SKU (#{inst[:sku_number]}): #{inst[:product_variant_code]}<br>
        Qty To Move: #{UtilityFunctions.delimited_number(inst[:unit][:quantity_to_move])}<br>
        Qty Offloaded: #{UtilityFunctions.delimited_number(inst[:unit][:quantity_offloaded])}<br>
      HTML
    end
  end
end
# rubocop:enable Metrics/ClassLength
