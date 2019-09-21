# frozen_string_literal: true

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

    def vehicle_job_unit(id)
      repo.find_vehicle_job_unit(id)
    end

    private

    def repo
      @repo ||= TripsheetsRepo.new
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
  end
end
