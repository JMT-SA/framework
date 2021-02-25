# frozen_string_literal: true

module SecurityApp
  class ProgramFunctionInteractor < BaseInteractor
    def repo
      @repo ||= MenuRepo.new
    end

    def program_function(id)
      repo.find_program_function(id)
    end

    def validate_program_function_params(params)
      ProgramFunctionSchema.call(params)
    end

    def create_program_function(params)
      res = validate_program_function_params(params)
      return validation_failed_response(res) if res.failure?

      id = repo.create_program_function(res)
      instance = program_function(id)
      success_response("Created program function #{instance.program_function_name}",
                       instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { program_function_name: ['This program function already exists'] }))
    end

    def update_program_function(id, params)
      res = validate_program_function_params(params)
      return validation_failed_response(res) if res.failure?

      repo.update_program_function(id, res)
      instance = program_function(id)
      success_response("Updated program function #{instance.program_function_name}",
                       instance)
    end

    def delete_program_function(id)
      name = program_function(id).program_function_name
      repo.delete_program_function(id)
      success_response("Deleted program function #{name}")
    end

    def link_user(program_function_id, user_ids)
      repo.transaction do
        repo.link_users(program_function_id, user_ids)
      end
      success_response('Linked users to program function')
    end

    def show_sql(id, webapp)
      DataToSql.new(webapp).sql_for(:program_functions, id)
    end
  end
end
