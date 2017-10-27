# frozen_string_literal: true

class BaseInteractor
  def initialize(user, client_settings, context, logger)
    @user = user
    @client_settings = client_settings
    @context = context
    @logger = logger
  end

  def exists?(entity, id)
    repo = SecurityGroupRepo.new
    repo.row_exists?(entity, id: id)
  end

  def validation_failed_response(validation_results)
    OpenStruct.new(success: false,
                   instance: {},
                   errors: validation_results.messages,
                   message: 'Validation error')
  end

  def success_response(message, instance = nil)
    OpenStruct.new(success: true,
                   instance: instance,
                   errors: {},
                   message: message)
  end
end
