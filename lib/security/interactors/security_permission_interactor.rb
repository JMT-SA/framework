# frozen_string_literal: true

module SecurityApp
  class SecurityPermissionInteractor < BaseInteractor
    def repo
      @repo ||= SecurityGroupRepo.new
    end

    def security_permission(cached = true)
      if cached
        @security_permission ||= repo.find_security_permission(@id)
      else
        @security_permission = repo.find_security_permission(@id)
      end
    end

    def validate_security_permission_params(params)
      SecurityPermissionSchema.call(params)
    end

    def create_security_permission(params)
      res = validate_security_permission_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      @id = repo.create_security_permission(res)
      success_response("Created security permission #{security_permission.security_permission}",
                       security_permission)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { security_permission: ['This security permission already exists'] }))
    end

    def update_security_permission(id, params)
      @id = id
      res = validate_security_permission_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      repo.update_security_permission(id, res)
      success_response("Updated security permission #{security_permission.security_permission}",
                       security_permission(false))
    end

    def delete_security_permission(id)
      @id = id
      name = security_permission.security_permission
      repo.delete_security_permission(id)
      success_response("Deleted security permission #{name}")
    end
  end
end
