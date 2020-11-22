# frozen_string_literal: true

module DevelopmentApp
  class RoleInteractor < BaseInteractor
    def repo
      @repo ||= RoleRepo.new
    end

    def role(id)
      repo.find_role(id)
    end

    def validate_role_params(params)
      RoleSchema.call(params)
    end

    def create_role(params)
      res = validate_role_params(params)
      return validation_failed_response(res) if res.failure?

      id = nil
      repo.transaction do
        id = repo.create_role(res)
      end
      instance = role(id)
      success_response("Created role #{instance.name}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { name: ['This role already exists'] }))
    end

    def update_role(id, params)
      res = validate_role_params(params)
      return validation_failed_response(res) if res.failure?

      repo.transaction do
        repo.update_role(id, res)
      end
      instance = role(id)
      success_response("Updated role #{instance.name}", instance)
    end

    def delete_role(id)
      name = role(id).name
      repo.transaction do
        repo.delete_role(id)
      end
      success_response("Deleted role #{name}")
    end
  end
end
