# frozen_string_literal: true

module DevelopmentApp
  class UserInteractor < BaseInteractor # rubocop:disable Metrics/ClassLength
    def prepare_password(user_validation)
      new_user = user_validation.to_h
      new_user[:password_hash] = BCrypt::Password.create(new_user.delete(:password))
      new_user.delete(:password_confirmation)
      new_user
    end

    def create_user(params)
      res = validate_new_user_params(params)
      # return validation_failed_response(hide_passwords_in_validation_errors(res)) if res.failure?
      return validation_failed_response(res) if res.failure?

      id = repo.create_user(prepare_password(res))
      instance = user(id)
      success_response("Created user #{instance.user_name}",
                       instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { login_name: ['This user already exists'] }))
    end

    def update_user(id, params)
      res = validate_user_params(params)
      return validation_failed_response(res) if res.failure? # if res.failure?

      repo.update_user(id, res)
      instance = user(id)
      success_response("Updated user #{instance.user_name}",
                       instance)
    end

    def delete_user(id)
      name = user(id).user_name
      res = repo.delete_or_deactivate_user(id)
      success_response("#{res.message} #{name}")
    end

    def change_user_password(id, params)
      return invalid_password unless matching_password?(id, params[:old_password])

      res = validate_change_user_params(params)
      # return validation_failed_response(hide_passwords_in_validation_errors(res)) if res.failure?
      return validation_failed_response(res) if res.failure?

      repo.transaction do
        repo.save_new_password(id, params[:password])
        log_transaction
      end
      instance = user(id)
      success_response('Your password has been changed', instance)
    end

    def set_user_password(id, params)
      # Force the user's password to the new value.
      res = validate_change_password(params)
      # return validation_failed_response(hide_passwords_in_validation_errors(res)) if res.failure?
      return validation_failed_response(res) if res.failure?

      repo.transaction do
        repo.save_new_password(id, params[:password])
        log_transaction
      end
      instance = user(id)
      success_response("Password for #{instance.user_name} has been changed", instance)
    end

    def set_user_permissions(id, ids, params)
      res = validate_user_permission(params)
      return validation_failed_response(res) if res.failure?

      res = repo.update_user_permission(ids, res.to_h[:security_group_id])
      success_response("Updated permissions for #{user(id).user_name}",
                       res.instance)
    end

    def change_user_permissions(id, params)
      user_permissions = Crossbeams::Config::UserPermissions.new.apply_params(params)
      repo.update_user(id, permission_tree: repo.hash_for_jsonb_col(user_permissions))
      instance = user(id)
      success_response("Updated user #{instance.user_name}",
                       instance)
    end

    def find_homepage(id)
      success_response('ok', OpenStruct.new(menu_repo.find_homepage(id)))
    end

    private

    def validate_user_permission(params)
      UserPermissionSchema.call(params)
    end

    def invalid_password
      validation_failed_response(OpenStruct.new(messages: { old_password: ['Incorrect password'] }))
    end

    # def hide_passwords_in_validation_errors(res)
    #   new_res = res.to_h
    #   new_res[:messages] = {}
    #   res.errors.to_h.each do |e, m|
    #     new_res[:messages][e] = m.map do |t|
    #       if t.start_with?('must not be equal')
    #         'cannot be the same as the old password'
    #       elsif t.start_with?('must be equal')
    #         'must match the password'
    #       else
    #         t
    #       end
    #     end
    #   end
    #   OpenStruct.new(new_res)
    # end

    def matching_password?(id, password)
      hs = repo.find_hash(:users, id)
      BCrypt::Password.new(hs[:password_hash]) == password
    end

    def repo
      @repo ||= UserRepo.new
    end

    def menu_repo
      @menu_repo ||= SecurityApp::MenuRepo.new
    end

    def user(id)
      repo.find_user(id)
    end

    def validate_new_user_params(params)
      # UserNewSchema.call(params)
      contract = UserNewContract.new
      contract.call(params)
    end

    def validate_user_params(params)
      UserSchema.call(params)
    end

    def validate_change_user_params(params)
      # UserChangeSchema.call(params)
      contract = UserChangeContract.new
      contract.call(params)
    end

    def validate_change_password(params)
      # UserPasswordSchema.call(params)
      contract = UserPasswordContract.new
      contract.call(params)
    end
  end
end
