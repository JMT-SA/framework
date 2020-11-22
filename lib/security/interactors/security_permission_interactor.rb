# frozen_string_literal: true

module SecurityApp
  class SecurityPermissionInteractor < BaseInteractor
    def repo
      @repo ||= SecurityGroupRepo.new
    end

    def security_permission(id)
      repo.find_security_permission(id)
    end

    def validate_security_permission_params(params)
      SecurityPermissionSchema.call(params)
    end

    def create_security_permission(params)
      res = validate_security_permission_params(params)
      return validation_failed_response(res) if res.failure?

      id = repo.create_security_permission(res)
      instance = security_permission(id)
      success_response("Created security permission #{instance.security_permission}",
                       instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { security_permission: ['This security permission already exists'] }))
    end

    def update_security_permission(id, params)
      res = validate_security_permission_params(params)
      return validation_failed_response(res) if res.failure?

      repo.update_security_permission(id, res)
      instance = security_permission(id)
      success_response("Updated security permission #{instance.security_permission}",
                       instance)
    end

    def delete_security_permission(id)
      name = security_permission(id).security_permission
      repo.delete_security_permission(id)
      success_response("Deleted security permission #{name}")
    end
  end
end
