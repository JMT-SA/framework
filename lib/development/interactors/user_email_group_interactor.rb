# frozen_string_literal: true

module DevelopmentApp
  class UserEmailGroupInteractor < BaseInteractor
    def repo
      @repo ||= UserRepo.new
    end

    def user_email_group(id)
      repo.find_user_email_group(id)
    end

    def validate_user_email_group_params(params)
      UserEmailGroupSchema.call(params)
    end

    def create_user_email_group(params)
      res = validate_user_email_group_params(params)
      return validation_failed_response(res) if res.failure?

      id = nil
      repo.transaction do
        id = repo.create_user_email_group(res)
        log_transaction
      end
      instance = user_email_group(id)
      success_response("Created user email group #{instance.mail_group}",
                       instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { mail_group: ['This user email group already exists'] }))
    end

    def update_user_email_group(id, params)
      res = validate_user_email_group_params(params)
      return validation_failed_response(res) if res.failure?

      repo.transaction do
        repo.update_user_email_group(id, res)
        log_transaction
      end
      instance = user_email_group(id)
      success_response("Updated user email group #{instance.mail_group}",
                       instance)
    end

    def delete_user_email_group(id)
      name = user_email_group(id).mail_group
      repo.transaction do
        repo.delete_user_email_group(id)
        log_transaction
      end
      success_response("Deleted user email group #{name}")
    end

    def link_users(id, user_ids)
      repo.transaction do
        repo.link_users(id, user_ids)
      end
      success_response('Linked users to email group')
    end
  end
end
