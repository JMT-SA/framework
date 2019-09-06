# frozen_string_literal: true

module PackMaterialApp
  class VehicleJobInteractor < BaseInteractor
    def repo
      @repo ||= TripsheetsRepo.new
    end

    def vehicle_job(id)
      repo.find_vehicle_job(id)
    end

    def validate_vehicle_job_params(params)
      VehicleJobSchema.call(params)
    end

    def create_vehicle_job(params)
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
      res = validate_vehicle_job_params(params)
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

    # def complete_a_vehicle_job(id, params)
    #   res = complete_a_record(:vehicle_jobs, id, params.merge(enqueue_job: false))
    #   if res.success
    #     success_response(res.message, vehicle_job(id))
    #   else
    #     failed_response(res.message, vehicle_job(id))
    #   end
    # end

    # def reopen_a_vehicle_job(id, params)
    #   res = reopen_a_record(:vehicle_jobs, id, params.merge(enqueue_job: false))
    #   if res.success
    #     success_response(res.message, vehicle_job(id))
    #   else
    #     failed_response(res.message, vehicle_job(id))
    #   end
    # end

    # def approve_or_reject_a_vehicle_job(id, params)
    #   res = if params[:approve_action] == 'a'
    #           approve_a_record(:vehicle_jobs, id, params.merge(enqueue_job: false))
    #         else
    #           reject_a_record(:vehicle_jobs, id, params.merge(enqueue_job: false))
    #         end
    #   if res.success
    #     success_response(res.message, vehicle_job(id))
    #   else
    #     failed_response(res.message, vehicle_job(id))
    #   end
    # end

    def assert_permission!(task, id = nil)
      res = TaskPermissionCheck::VehicleJob.call(task, id)
      raise Crossbeams::TaskNotPermittedError, res.message unless res.success
    end
  end
end
