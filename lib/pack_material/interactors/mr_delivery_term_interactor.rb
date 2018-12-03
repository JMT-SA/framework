# frozen_string_literal: true

module PackMaterialApp
  class MrDeliveryTermInteractor < BaseInteractor
    def repo
      @repo ||= ReplenishRepo.new
    end

    def mr_delivery_term(id)
      repo.find_mr_delivery_term(id)
    end

    def validate_mr_delivery_term_params(params)
      MrDeliveryTermSchema.call(params)
    end

    def create_mr_delivery_term(params)
      res = validate_mr_delivery_term_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      id = nil
      repo.transaction do
        id = repo.create_mr_delivery_term(res)
        log_status('mr_delivery_terms', id, 'CREATED')
        log_transaction
      end
      instance = mr_delivery_term(id)
      success_response("Created delivery term #{instance.delivery_term_code}",
                       instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { delivery_term_code: ['This delivery term already exists'] }))
    end

    def update_mr_delivery_term(id, params)
      res = validate_mr_delivery_term_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      repo.transaction do
        repo.update_mr_delivery_term(id, res)
        log_transaction
      end
      instance = mr_delivery_term(id)
      success_response("Updated delivery term #{instance.delivery_term_code}",
                       instance)
    end

    def delete_mr_delivery_term(id)
      name = mr_delivery_term(id).delivery_term_code
      repo.transaction do
        repo.delete_mr_delivery_term(id)
        log_status('mr_delivery_terms', id, 'DELETED')
        log_transaction
      end
      success_response("Deleted delivery term #{name}")
    end
  end
end
