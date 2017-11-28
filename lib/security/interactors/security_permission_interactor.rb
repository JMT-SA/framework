# frozen_string_literal: true

class SecurityPermissionInteractor < BaseInteractor
  def repo
    @repo ||= SecurityGroupRepo.new
  end

  def security_permission(cached = true)
    if cached
      @security_permission ||= repo.find(:security_permissions, SecurityPermission, @id)
    else
      @security_permission = repo.find(:security_permissions, SecurityPermission, @id)
    end
  end

  def validate_security_permission_params(params)
    SecurityPermissionSchema.call(params)
  end

  def create_security_permission(params)
    res = validate_security_permission_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    @id = repo.create(:security_permissions, res.to_h)
    success_response("Created security permission #{security_permission.security_permission}",
                     security_permission)
  end

  def update_security_permission(id, params)
    @id = id
    res = validate_security_permission_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    repo.update(:security_permissions, id, res.to_h)
    success_response("Updated security permission #{security_permission.security_permission}",
                     security_permission(false))
  end

  def delete_security_permission(id)
    @id = id
    name = security_permission.security_permission
    repo.delete(:security_permissions, id)
    success_response("Deleted security permission #{name}")
  end
end
