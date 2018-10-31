# frozen_string_literal: true

module MasterfilesApp
  class MrCostTypeInteractor < BaseInteractor
    def repo
      @repo ||= GeneralRepo.new
    end

    def mr_cost_type(id)
      repo.find_mr_cost_type(id)
    end

    def validate_mr_cost_type_params(params)
      MrCostTypeSchema.call(params)
    end

    def create_mr_cost_type(params)
      res = validate_mr_cost_type_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      id = nil
      repo.transaction do
        id = repo.create_mr_cost_type(res)
        log_status('mr_cost_types', id, 'CREATED')
        log_transaction
      end
      instance = mr_cost_type(id)
      success_response("Created mr cost type #{instance.cost_code_string}",
                       instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { cost_code_string: ['This mr cost type already exists'] }))
    end

    def update_mr_cost_type(id, params)
      res = validate_mr_cost_type_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      repo.transaction do
        repo.update_mr_cost_type(id, res)
        log_transaction
      end
      instance = mr_cost_type(id)
      success_response("Updated mr cost type #{instance.cost_code_string}",
                       instance)
    end

    def delete_mr_cost_type(id)
      name = mr_cost_type(id).cost_code_string
      repo.transaction do
        repo.delete_mr_cost_type(id)
        log_status('mr_cost_types', id, 'DELETED')
        log_transaction
      end
      success_response("Deleted mr cost type #{name}")
    end
  end
end
