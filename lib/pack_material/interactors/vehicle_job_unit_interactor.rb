# frozen_string_literal: true

module PackMaterialApp
  class VehicleJobUnitInteractor < BaseInteractor
    def create_vehicle_job_unit(params)
      res = validate_vehicle_job_unit_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      id = nil
      repo.transaction do
        id = repo.create_vehicle_job_unit(res)
        log_status('vehicle_job_units', id, 'CREATED')
        log_transaction
      end
      instance = vehicle_job_unit(id)
      success_response("Created vehicle job unit #{instance.id}",
                       instance)
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
      success_response("Updated vehicle job unit #{instance.id}",
                       instance)
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

    # def complete_a_vehicle_job_unit(id, params)
    #   res = complete_a_record(:vehicle_job_units, id, params.merge(enqueue_job: false))
    #   if res.success
    #     success_response(res.message, vehicle_job_unit(id))
    #   else
    #     failed_response(res.message, vehicle_job_unit(id))
    #   end
    # end

    # def reopen_a_vehicle_job_unit(id, params)
    #   res = reopen_a_record(:vehicle_job_units, id, params.merge(enqueue_job: false))
    #   if res.success
    #     success_response(res.message, vehicle_job_unit(id))
    #   else
    #     failed_response(res.message, vehicle_job_unit(id))
    #   end
    # end

    # def approve_or_reject_a_vehicle_job_unit(id, params)
    #   res = if params[:approve_action] == 'a'
    #           approve_a_record(:vehicle_job_units, id, params.merge(enqueue_job: false))
    #         else
    #           reject_a_record(:vehicle_job_units, id, params.merge(enqueue_job: false))
    #         end
    #   if res.success
    #     success_response(res.message, vehicle_job_unit(id))
    #   else
    #     failed_response(res.message, vehicle_job_unit(id))
    #   end
    # end

    def assert_permission!(task, id = nil)
      res = TaskPermissionCheck::VehicleJobUnit.call(task, id)
      raise Crossbeams::TaskNotPermittedError, res.message unless res.success
    end

    private

    def repo
      @repo ||= TripsheetsRepo.new
    end

    def vehicle_job_unit(id)
      repo.find_vehicle_job_unit(id)
    end

    def validate_vehicle_job_unit_params(params)
      VehicleJobUnitSchema.call(params)
    end
  end
end
