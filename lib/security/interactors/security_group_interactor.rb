# frozen_string_literal: true

class SecurityGroupInteractor < BaseInteractor
  def security_group_repo
    @security_group_repo ||= SecurityGroupRepo.new
  end

  def security_group(cached = true)
    if cached
      @security_group ||= security_group_repo.find(@id)
    else
      @security_group = security_group_repo.find(@id)
    end
  end

  def validate_security_group_params(params)
    SecurityGroupSchema.call(params)
  end

  # --| actions
  def create_security_group(params)
    res = validate_security_group_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    # res = validate_security_group
    @id = security_group_repo.create(res.to_h)
    success_response("Created security group #{security_group.security_group_name}",
                     security_group)
  end

  def update_security_group(id, params)
    @id = id
    res = validate_security_group_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    # res = validate_security_group... etc.
    security_group_repo.update(id, res.to_h)
    success_response("Updated security group #{security_group.security_group_name}",
                     security_group(false))
  end

  def delete_security_group(id)
    @id = id
    name = security_group.security_group_name
    security_group_repo.delete_with_permissions(id)
    success_response("Deleted security group #{name}")
  end

  def assign_security_permissions(id, params)
    if params[:security_permissions]
      security_group_repo.assign_security_permissions(id, params[:security_permissions].map(&:to_i))
      security_group_ex = security_group_repo.find_with_permissions(id)
      success_response("Updated permissions on security group #{security_group_ex.security_group_name}",
                       security_group_ex)
    else
      validation_failed_response(OpenStruct.new(messages: { security_permissions: ['You did not choose a permission'] }))
    end
  end
end
