# frozen_string_literal: true

module MasterfilesApp
  class UomInteractor < BaseInteractor
    def repo
      @repo ||= GeneralRepo.new
    end

    def uom(id)
      repo.find_uom(id)
    end

    def validate_uom_params(params)
      UomSchema.call(params)
    end

    def create_uom(params) # rubocop:disable Metrics/AbcSize
      res = validate_uom_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      id = nil
      repo.transaction do
        id = repo.create_uom(res)
        log_status('uoms', id, 'CREATED')
        log_transaction
      end
      instance = uom(id)
      success_response("Created uom #{instance.uom_code}",
                       instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { uom_code: ['This uom already exists'] }))
    end

    def update_uom(id, params)
      res = validate_uom_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      repo.transaction do
        repo.update_uom(id, res)
        log_transaction
      end
      instance = uom(id)
      success_response("Updated uom #{instance.uom_code}",
                       instance)
    end

    def delete_uom(id)
      name = uom(id).uom_code
      repo.transaction do
        repo.delete_uom(id)
        log_status('uoms', id, 'DELETED')
        log_transaction
      end
      success_response("Deleted uom #{name}")
    end
  end
end
