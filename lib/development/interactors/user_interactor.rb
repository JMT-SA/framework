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

  def validate_new_user_params(params)
    UserNewSchema.call(params)
  end

  def validate_user_params(params)
    UserSchema.call(params)
  end

  def prepare_password(user_validation)
    new_user = user_validation.to_h
    new_user[:password_hash] = BCrypt::Password.create(new_user.delete(:password))
    new_user.delete(:password_confirmation)
    new_user
  end

  def create_user(params)
    res = validate_new_user_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    @id = repo.create(:users, prepare_password(res))
    success_response("Created user #{user(false).user_name}",
                     user(false))
  rescue Sequel::UniqueConstraintViolation
    validation_failed_response(OpenStruct.new(messages: { login_name: ['This user already exists'] }))
  end

  def update_user(id, params)
    @id = id
    res = validate_user_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    repo.update(:users, id, res.to_h)
    success_response("Updated user #{user.user_name}",
                     user(false))
  end

  def delete_user(id)
    @id = id
    name = user(false).user_name
    repo.delete(:users, id)
    success_response("Deleted user #{name}")
  end
end
