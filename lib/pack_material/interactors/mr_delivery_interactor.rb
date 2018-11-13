# frozen_string_literal: true

module PackMaterialApp
  class MrDeliveryInteractor < BaseInteractor
    def repo
      @repo ||= ReplenishRepo.new
    end

    def mr_delivery(id)
      repo.find_mr_delivery(id)
    end

    def validate_mr_delivery_params(params)
      MrDeliverySchema.call(params)
    end

    def create_mr_delivery(params)
      res = validate_mr_delivery_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      id = nil
      repo.transaction do
        id = repo.create_mr_delivery(res)
        log_status('mr_deliveries', id, 'CREATED')
        log_transaction
      end
      instance = mr_delivery(id)
      success_response("Created delivery #{instance.delivery_number}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { base: ['This delivery already exists'] }))
    end

    def update_mr_delivery(id, params)
      res = validate_mr_delivery_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      repo.transaction do
        repo.update_mr_delivery(id, res)
        log_transaction
      end
      instance = mr_delivery(id)
      success_response("Updated delivery #{instance.delivery_number}", instance)
    end

    def verify_mr_delivery(id)
      res = nil
      repo.transaction do
        res = repo.verify_mr_delivery(id)
        log_transaction
      end
      res
    end

    def delete_mr_delivery(id)
      name = mr_delivery(id).delivery_number
      repo.transaction do
        repo.delete_mr_delivery(id)
        log_status('mr_deliveries', id, 'DELETED')
        log_transaction
      end
      success_response("Deleted delivery #{name}")
    end
  end
end
