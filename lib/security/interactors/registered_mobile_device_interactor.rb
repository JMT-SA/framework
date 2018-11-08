# frozen_string_literal: true

module SecurityApp
  class RegisteredMobileDeviceInteractor < BaseInteractor
    def repo
      @repo ||= RegisteredMobileDeviceRepo.new
    end

    def registered_mobile_device(id)
      repo.find_registered_mobile_device(id)
    end

    def registered_mobile_device_with_start_page(id)
      repo.find_registered_mobile_device_with_start_page(id)
    end

    def validate_registered_mobile_device_params(params)
      RegisteredMobileDeviceSchema.call(params)
    end

    def create_registered_mobile_device(params) # rubocop:disable Metrics/AbcSize
      res = validate_registered_mobile_device_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      id = nil
      repo.transaction do
        id = repo.create_registered_mobile_device(res)
        log_status('registered_mobile_devices', id, 'CREATED')
        log_transaction
      end
      instance = registered_mobile_device_with_start_page(id)
      success_response("Created registered mobile device #{instance[:ip_address]}",
                       instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { ip_address: ['This registered mobile device already exists'] }))
    end

    def update_registered_mobile_device(id, params)
      res = validate_registered_mobile_device_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      repo.transaction do
        repo.update_registered_mobile_device(id, res)
        log_transaction
      end
      instance = registered_mobile_device_with_start_page(id)
      success_response("Updated registered mobile device #{instance[:ip_address]}",
                       instance)
    end

    def delete_registered_mobile_device(id)
      name = registered_mobile_device(id).ip_address
      repo.transaction do
        repo.delete_registered_mobile_device(id)
        log_status('registered_mobile_devices', id, 'DELETED')
        log_transaction
      end
      success_response("Deleted registered mobile device #{name}")
    end
  end
end
