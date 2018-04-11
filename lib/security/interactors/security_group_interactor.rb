# frozen_string_literal: true

module SecurityApp
  class SecurityGroupInteractor < BaseInteractor
    def repo
      @repo ||= SecurityGroupRepo.new
    end

    def security_group(cached = true)
      if cached
        @security_group ||= repo.find_security_group(@id)
      else
        @security_group = repo.find_security_group(@id)
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
      DB.transaction do
        @id = repo.create_security_group(res)
        log_transaction
      end
      success_response("Created security group #{security_group.security_group_name}",
                       security_group)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { security_group_name: ['This security group already exists'] }))
    end

    def update_security_group(id, params)
      @id = id
      res = validate_security_group_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      # res = validate_security_group... etc.
      DB.transaction do
        repo.update_security_group(id, res)
        log_transaction
      end
      success_response("Updated security group #{security_group.security_group_name}",
                       security_group(false))
    end

    def delete_security_group(id)
      @id = id
      name = security_group.security_group_name
      DB.transaction do
        repo.delete_with_permissions(id)
        log_transaction
      end
      success_response("Deleted security group #{name}")
    end

    def assign_security_permissions(id, params)
      if params[:security_permissions]
        DB.transaction do
          repo.assign_security_permissions(id, params[:security_permissions].map(&:to_i))
          log_transaction
        end
        security_group_ex = repo.find_with_permissions(id)
        success_response("Updated permissions on security group #{security_group_ex.security_group_name}",
                         security_group_ex)
      else
        validation_failed_response(OpenStruct.new(messages: { security_permissions: ['You did not choose a permission'] }))
      end
    end
  end
end
