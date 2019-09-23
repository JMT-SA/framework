# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength

module PackMaterialApp
  class VehicleJobUnitInteractor < BaseInteractor
    def create_vehicle_job_unit(_parent_id, params) # rubocop:disable Metrics/AbcSize
      # TODO: Can edit parent?
      # params[:mr_delivery_id] = parent_id
      #       can_create = TaskPermissionCheck::MrDeliveryItem.call(:create, delivery_id: parent_id)
      #       if can_create.success
      res = validate_new_vehicle_job_unit_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      id = nil
      repo.transaction do
        id = repo.create_vehicle_job_unit(res)
        log_status('vehicle_job_units', id, 'CREATED')
        log_transaction
      end
      instance = vehicle_job_unit(id)
      success_response("Created vehicle job unit #{instance.id}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { id: ['This vehicle job unit already exists'] }))
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def update_vehicle_job_unit(id, params)
      res = validate_vehicle_job_unit_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      repo.transaction do
        repo.update_vehicle_job_unit(id, res)
        log_transaction
      end
      instance = vehicle_job_unit(id)
      success_response("Updated vehicle job unit #{instance.id}", instance)
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def load_vehicle_unit(params) # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
      vehicle_job_id = repo.vehicle_job_id_from_number(params[:tripsheet_number])
      # vehicle_job_unit_id =
      # Move to parent_interactor
      can_load = assert_permission!(:load, vehicle_job_unit_id)
      if can_load
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
      else
        failed_response(can_load.message)
      end
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def delete_vehicle_job_unit(id)
      name = vehicle_job_unit(id).id
      repo.transaction do
        repo.delete_vehicle_job_unit(id)
        log_status('vehicle_job_units', id, 'DELETED')
        log_transaction
      end
      success_response("Deleted vehicle job unit #{name}")
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def inline_update(id, params)
      assert_permission!(:update, id)
      res = validate_vehicle_job_unit_inline_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      repo.transaction do
        repo.inline_update_vehicle_job_unit(id, res)
        log_status('vehicle_job_units', id, 'INLINE UPDATE')
        log_transaction
      end
      success_response('Updated vehicle job unit quantity to move')
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def assert_permission!(task, id = nil)
      res = TaskPermissionCheck::VehicleJobUnit.call(task, id)
      raise Crossbeams::TaskNotPermittedError, res.message unless res.success
    end

    def assert_parent_permission!(task, id = nil)
      res = TaskPermissionCheck::VehicleJob.call(task, id)
      raise Crossbeams::TaskNotPermittedError, res.message unless res.success
    end

    def check_button_permissions(id)
      parent_id = vehicle_job_unit(id)&.vehicle_job_id
      {
        can_confirm_arrival: assert_parent_permission(:can_confirm_arrival, parent_id),
        can_load: assert_parent_permission(:can_load, parent_id)
      }
    end

    def assert_parent_permission(task, id = nil)
      res = TaskPermissionCheck::VehicleJob.call(task, id)
      res.success
    end

    private

    def repo
      @repo ||= TripsheetsRepo.new
    end

    def replenish_repo
      @replenish_repo ||= ReplenishRepo.new
    end

    def vehicle_job_unit(id)
      repo.find_vehicle_job_unit(id)
    end

    def vehicle_job(vehicle_job_id)
      repo.find_vehicle_job(vehicle_job_id)
    end

    def validate_new_vehicle_job_unit_params(params)
      NewVehicleJobUnitSchema.call(params)
    end

    def validate_vehicle_job_unit_params(params)
      VehicleJobUnitSchema.call(params)
    end

    def validate_vehicle_job_unit_inline_params(params)
      VehicleJobUnitInlineSchema.call(params)
    end

    def validate_load_vehicle_unit_params(params)
      VehicleJobUnitLoadSchema.call(params)
    end

    def html_vehicle_load_progress_report(vehicle_job_id, sku_id, location_id) # rubocop:disable Metrics/AbcSize
      inst = repo.vehicle_load_progress_report_values(vehicle_job_id, sku_id, location_id)
      <<~HTML
        Tripsheet (#{inst[:tripsheet_number]}): #{inst[:done]} of #{inst[:total_units]} units.<br>
        Last scan:<br>
        LOC: #{inst[:location_code]}<br>
        SKU (#{inst[:sku_number]}): #{inst[:product_variant_code]}<br>
        Qty: was #{UtilityFunctions.delimited_number(inst[:item][:system_quantity])} now #{UtilityFunctions.delimited_number(inst[:item][:actual_quantity])} (#{inst[:item][:inventory_uom_code]})<br>
      HTML
    end
  end
end
# rubocop:enable Metrics/ClassLength
