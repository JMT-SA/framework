# frozen_string_literal: true

module PackMaterialApp
  class LocationInteractor < BaseInteractor
    def repo
      @repo ||= LocationRepo.new
    end

    def location(id)
      repo.find_location(id)
    end

    def validate_location_params(params)
      LocationSchema.call(params)
    end

    def create_root_location(params)
      res = validate_location_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      id = nil
      repo.transaction do
        id = repo.create_root_location(res)
        log_transaction
      end
      instance = location(id)
      success_response("Created location #{instance.location_code}",
                       instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { location_code: ['This location already exists'] }))
    end

    def create_location(parent_id, params)
      res = validate_location_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      id = nil
      repo.transaction do
        p ">>> INT: #{parent_id}"
        id = repo.create_child_location(parent_id, res)
        log_transaction
      end
      instance = location(id)
      success_response("Created location #{instance.location_code}",
                       instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { location_code: ['This location already exists'] }))
    end

    def update_location(id, params)
      res = validate_location_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      repo.transaction do
        repo.update_location(id, res)
        log_transaction
      end
      instance = location(id)
      success_response("Updated location #{instance.location_code}",
                       instance)
    end

    def delete_location(id)
      return failed_response('Cannot delete this location - it has sub-locations') if repo.location_has_children(id)
      name = location(id).location_code
      repo.transaction do
        repo.delete_location(id)
        log_transaction
      end
      success_response("Deleted location #{name}")
    end

    def link_assignments(id, multiselect_ids)
      res = nil
      repo.transaction do
        res = repo.link_assignments(id, multiselect_ids)
      end
      return res unless res.success
      success_response('Assignments linked successfully')
    end

    def link_storage_types(id, multiselect_ids)
      res = nil
      repo.transaction do
        res = repo.link_storage_types(id, multiselect_ids)
      end
      return res unless res.success
      success_response('Storage types linked successfully')
    end
  end
end
