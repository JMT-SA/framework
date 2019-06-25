# frozen_string_literal: true

module MasterfilesApp
  class LocationStorageDefinitionInteractor < BaseInteractor
    def repo
      @repo ||= LocationRepo.new
    end

    def location_storage_definition(id)
      repo.find_location_storage_definition(id)
    end

    def validate_location_storage_definition_params(params)
      LocationStorageDefinitionSchema.call(params)
    end

    def create_location_storage_definition(params) # rubocop:disable Metrics/AbcSize
      res = validate_location_storage_definition_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      id = nil
      repo.transaction do
        id = repo.create_location_storage_definition(res)
        log_status('location_storage_definitions', id, 'CREATED')
        log_transaction
      end
      instance = location_storage_definition(id)
      success_response("Created location storage definition #{instance.storage_definition_code}",
                       instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { storage_definition_code: ['This location storage definition already exists'] }))
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def update_location_storage_definition(id, params)
      res = validate_location_storage_definition_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      repo.transaction do
        repo.update_location_storage_definition(id, res)
        log_transaction
      end
      instance = location_storage_definition(id)
      success_response("Updated location storage definition #{instance.storage_definition_code}",
                       instance)
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def delete_location_storage_definition(id)
      name = location_storage_definition(id).storage_definition_code
      repo.transaction do
        repo.delete_location_storage_definition(id)
        log_status('location_storage_definitions', id, 'DELETED')
        log_transaction
      end
      success_response("Deleted location storage definition #{name}")
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end
  end
end
