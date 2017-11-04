# frozen_string_literal: true

class UserInteractor < BaseInteractor
  def user_repo
    @user_repo ||= UserRepo.new
  end

  def user(cached = true)
    if cached
      @user ||= user_repo.find(@id)
    else
      @user = user_repo.find(@id)
    end
  end

  def validate_user_params(params)
    UserSchema.call(params)
  end

  def create_user(params)
    res = validate_user_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    # res = validate_user... etc.
    @id = user_repo.create(res.to_h)
    success_response("Created user #{user.user_name}",
                     user)
  end

  def update_user(id, params)
    @id = id
    res = validate_user_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    # res = validate_user... etc.
    user_repo.update(id, res.to_h)
    success_response("Updated user #{user.user_name}",
                     user(false))
  end

  def delete_user(id)
    @id = id
    name = user.user_name
    user_repo.delete(id)
    success_response("Deleted user #{name}")
  end
end
