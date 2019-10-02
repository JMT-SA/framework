# frozen_string_literal: true

module PackMaterialApp
  class VehicleJobUnitInteractor < BaseInteractor
    def create_vehicle_job_unit(parent_id, params) # rubocop:disable Metrics/AbcSize
      assert_parent_permission!(:edit_header, parent_id)
      res = validate_new_vehicle_job_unit_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      id = nil
      repo.transaction do
        id = repo.create_vehicle_job_unit(res)
        log_status('vehicle_job_units', id, 'CREATED')
        log_transaction
      end
      instance = vehicle_job_unit(id)
      success_response("Created Tripsheet Item #{instance.id}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { id: ['This Tripsheet Item already exists'] }))
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
      success_response("Updated Tripsheet Item #{instance.id}", instance)
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
      success_response("Deleted Tripsheet Item #{name}")
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
      success_response('Updated Tripsheet Item quantity to move')
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def assert_permission!(task, id = nil)
      res = TaskPermissionCheck::VehicleJobUnit.call(task, id)
      raise Crossbeams::TaskNotPermittedError, res.message unless res.success
    end

    def assert_parent_permission!(task, id = nil)
      res = TaskPermissionCheck::VehicleJob.call(task, id, @user)
      raise Crossbeams::TaskNotPermittedError, res.message unless res.success
    end

    def check_button_permissions(id)
      parent_id = vehicle_job_unit(id)&.vehicle_job_id
      {
        can_confirm_arrival: assert_parent_permission(:can_confirm_arrival, parent_id),
        can_mark_as_loaded: assert_parent_permission(:can_mark_as_loaded, parent_id)
      }
    end

    def assert_parent_permission(task, id = nil)
      res = TaskPermissionCheck::VehicleJob.call(task, id, @user)
      res.success
    end

    private

    def repo
      @repo ||= TripsheetsRepo.new
    end

    def vehicle_job_unit(id)
      repo.find_vehicle_job_unit(id)
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
