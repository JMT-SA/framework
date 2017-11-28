# frozen_string_literal: true

class UserInteractor < BaseInteractor
  def repo
    @repo ||= UserRepo.new
  end

  def user(cached = true)
    if cached
      @user ||= repo.find(:users, User, @id)
    else
      @user = repo.find(:users, User, @id)
    end
  end

  def validate_user_params(params)
    UserSchema.call(params)
  end

  def create_user(params)
    res = validate_user_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    # res = validate_user... etc.
    @id = repo.create(:users, res.to_h)
    success_response("Created user #{user.user_name}",
                     user)
  end

  def update_user(id, params)
    @id = id
    res = validate_user_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    # res = validate_user... etc.
    repo.update(:users, id, res.to_h)
    success_response("Updated user #{user.user_name}",
                     user(false))
  end

  def delete_user(id)
    @id = id
    name = user.user_name
    repo.delete(:users, id)
    success_response("Deleted user #{name}")
  end
end
