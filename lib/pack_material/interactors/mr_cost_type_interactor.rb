# frozen_string_literal: true

module PackMaterialApp
  class MrCostTypeInteractor < BaseInteractor
    def repo
      @repo ||= ReplenishRepo.new
    end

    def mr_cost_type(id)
      repo.find_mr_cost_type(id)
    end

    def validate_mr_cost_type_params(params)
      MrCostTypeSchema.call(params)
    end

    def create_mr_cost_type(params) # rubocop:disable Metrics/AbcSize
      res = validate_mr_cost_type_params(params)
      return validation_failed_response(res) if res.failure?

      id = nil
      repo.transaction do
        id = repo.create_mr_cost_type(res)
        log_status('mr_cost_types', id, 'CREATED')
        log_transaction
      end
      instance = mr_cost_type(id)
      success_response("Created cost type #{instance.cost_type_code}",
                       instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { cost_type_code: ['This cost type already exists'] }))
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def update_mr_cost_type(id, params)
      res = validate_mr_cost_type_params(params)
      return validation_failed_response(res) if res.failure?

      repo.transaction do
        repo.update_mr_cost_type(id, res)
        log_transaction
      end
      instance = mr_cost_type(id)
      success_response("Updated cost type #{instance.cost_type_code}",
                       instance)
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def delete_mr_cost_type(id)
      name = mr_cost_type(id).cost_type_code
      repo.transaction do
        repo.delete_mr_cost_type(id)
        log_status('mr_cost_types', id, 'DELETED')
        log_transaction
      end
      success_response("Deleted cost type #{name}")
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end
  end
end
