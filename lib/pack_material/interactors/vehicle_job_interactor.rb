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

    def assert_permission!(task, id = nil)
      res = TaskPermissionCheck::VehicleJob.call(task, id)
      raise Crossbeams::TaskNotPermittedError, res.message unless res.success
    end

    def can_confirm_arrival(id)
      res = TaskPermissionCheck::VehicleJob.call(:can_confirm_arrival, id)
      res.success
    end

    def can_mark_as_loaded(id)
      res = TaskPermissionCheck::VehicleJob.call(:can_load, id)
      res.success
    end

    private

    def repo
      @repo ||= TripsheetsRepo.new
    end

    def vehicle_job(id)
      repo.find_vehicle_job(id)
    end

    def validate_vehicle_job_params(params)
      VehicleJobSchema.call(params)
    end
  end
end
