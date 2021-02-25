# frozen_string_literal: true

module MasterfilesApp
  class AccountCodeInteractor < BaseInteractor
    def create_account_code(params)
      res = validate_account_code_params(params)
      return validation_failed_response(res) if res.failure?

      id = nil
      repo.transaction do
        id = repo.create_account_code(res)
        log_status('account_codes', id, 'CREATED')
        log_transaction
      end
      instance = account_code(id)
      success_response("Created account code #{instance.description}",
                       instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { description: ['This account code already exists'] }))
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def update_account_code(id, params)
      res = validate_account_code_params(params)
      return validation_failed_response(res) if res.failure?

      repo.transaction do
        repo.update_account_code(id, res)
        log_transaction
      end
      instance = account_code(id)
      success_response("Updated account code #{instance.description}",
                       instance)
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def delete_account_code(id)
      name = account_code(id).description
      repo.transaction do
        repo.delete_account_code(id)
        log_status('account_codes', id, 'DELETED')
        log_transaction
      end
      success_response("Deleted account code #{name}")
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    private

    def repo
      @repo ||= GeneralRepo.new
    end

    def account_code(id)
      repo.find_account_code(id)
    end

    def validate_account_code_params(params)
      AccountCodeSchema.call(params)
    end
  end
end
