# frozen_string_literal: true

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

    # def vehicle_job_confirm_arrival(id)
    # TODO: Offload to receiving bay
    #   assert_permission!(:approve, id)
    #   repo.transaction do
    #     log_transaction
    #
    #     log_status('vehicle_jobs', id, 'APPROVED')
    #     repo.approve_vehicle_job(id)
    #
    #     instance = vehicle_job(id)
    #     success_response('Approved Vehicle Job', instance)
    #   end
    # rescue Crossbeams::TaskNotPermittedError => e
    #   failed_response(e.message)
    # rescue Crossbeams::InfoError => e
    #   failed_response(e.message)
    # end

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

    def load_vehicle_unit(params) # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
      vehicle_job_id = repo.vehicle_job_id_from_number(params[:tripsheet_number])
      assert_permission!(:can_load, vehicle_job_id)

      res = validate_load_vehicle_unit_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      sku_ids = replenish_repo.sku_ids_from_numbers(params[:sku_number])
      sku_id = sku_ids[0]
      qty = params[:quantity]

      location_id = replenish_repo.resolve_location_id_from_scan(params[:location], params[:location_scan_field])
      return failed_response('Location not found, please use location short code') unless location_id

      location_id = Integer(location_id)

      repo.transaction do
        log_transaction
        res = repo.rmd_load_vehicle_unit(
          mr_sku_id: sku_id,
          quantity_to_load: qty,
          location_id: location_id,
          vehicle_job_id: vehicle_job_id
        )
        raise Crossbeams::InfoError, res.message unless res.success

        vehicle_job_unit = res.instance
        vehicle_job = vehicle_job(vehicle_job_id)

        log_status('vehicle_job_units', res.instance[:id], vehicle_job_unit[:loaded] ? 'LOADED' : 'LOADING')
        log_status('vehicle_jobs', vehicle_job_id, vehicle_job.loaded ? 'LOADED' : 'LOADING')
        html_report = html_vehicle_load_progress_report(vehicle_job_id, sku_id, location_id)
        success_response('Successful vehicle unit load', OpenStruct.new(vehicle_job_id: vehicle_job_id, report: html_report))
      end
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def assert_permission!(task, id = nil)
      res = check_permission(task, id)
      raise Crossbeams::TaskNotPermittedError, res.message unless res.success
    end

    def check_permission(task, id = nil)
      TaskPermissionCheck::VehicleJob.call(task, id)
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

    def validate_load_vehicle_unit_params(params)
      VehicleJobUnitLoadSchema.call(params)
    end

    def html_vehicle_load_progress_report(vehicle_job_id, sku_id, location_id) # rubocop:disable Metrics/AbcSize
      inst = repo.vehicle_load_progress_report(vehicle_job_id, sku_id, location_id)
      <<~HTML
        Tripsheet (#{inst[:tripsheet_number]}): #{inst[:done]} of #{inst[:total_units]} units.<br>
        Last scan:<br>
        LOC: #{inst[:location_code]}<br>
        SKU (#{inst[:sku_number]}): #{inst[:product_variant_code]}<br>
        Qty To Move: #{UtilityFunctions.delimited_number(inst[:unit][:quantity_to_move])}<br>
        Qty Loaded: #{UtilityFunctions.delimited_number(inst[:unit][:quantity_loaded])}<br>
      HTML
    end
  end
end
