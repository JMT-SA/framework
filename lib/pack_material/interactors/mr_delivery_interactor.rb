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
      can_create = TaskPermissionCheck::MrDelivery.call(:create)
      if can_create.success
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
      else
        failed_response(can_create.message)
      end
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { base: ['This delivery already exists'] }))
    end

    def update_mr_delivery(id, params)
      can_update = TaskPermissionCheck::MrDelivery.call(:update, id)
      if can_update.success
        res = validate_mr_delivery_params(params)
        return validation_failed_response(res) unless res.messages.empty?
        repo.transaction do
          repo.update_mr_delivery(id, res)
          log_transaction
        end
        instance = mr_delivery(id)
        success_response("Updated delivery #{instance.delivery_number}", instance)
      else
        failed_response(can_update.message)
      end
    end

    def verify_mr_delivery(id) # rubocop:disable Metrics/AbcSize
      can_verify = TaskPermissionCheck::MrDelivery.call(:verify, id)
      if can_verify.success
        repo.transaction do
          repo.verify_mr_delivery(id)
          log_transaction
          log_status('mr_deliveries', id, 'VERIFIED')
          PackMaterialApp::CreateSKUS.call(id)
          instance = mr_delivery(id)
          success_response("Verified delivery #{instance.delivery_number}", instance)
        end
      else
        failed_response(can_verify.message)
      end
    end

    def delete_mr_delivery(id)
      can_delete = TaskPermissionCheck::MrDelivery.call(:delete, id)
      if can_delete.success
        name = mr_delivery(id).delivery_number
        repo.transaction do
          repo.delete_mr_delivery(id)
          log_transaction
          log_status('mr_deliveries', id, 'DELETED')
        end
        success_response("Deleted delivery #{name}")
      else
        failed_response(can_delete.message)
      end
    end
  end
end
