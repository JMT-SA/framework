# frozen_string_literal: true

module PackMaterialApp
  class VehicleInteractor < BaseInteractor
    def repo
      @repo ||= TripsheetsRepo.new
    end

    def vehicle(id)
      repo.find_vehicle(id)
    end

    def validate_vehicle_params(params)
      VehicleSchema.call(params)
    end

    def create_vehicle(params) # rubocop:disable Metrics/AbcSize
      res = validate_vehicle_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      id = nil
      repo.transaction do
        id = repo.create_vehicle(res)
        log_status('vehicles', id, 'CREATED')
        log_transaction
      end
      instance = vehicle(id)
      success_response("Created vehicle #{instance.vehicle_code}",
                       instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { vehicle_code: ['This vehicle already exists'] }))
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def update_vehicle(id, params)
      res = validate_vehicle_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      repo.transaction do
        repo.update_vehicle(id, res)
        log_transaction
      end
      instance = vehicle(id)
      success_response("Updated vehicle #{instance.vehicle_code}",
                       instance)
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def delete_vehicle(id)
      name = vehicle(id).vehicle_code
      repo.transaction do
        repo.delete_vehicle(id)
        log_status('vehicles', id, 'DELETED')
        log_transaction
      end
      success_response("Deleted vehicle #{name}")
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end
  end
end
