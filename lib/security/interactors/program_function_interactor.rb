# frozen_string_literal: true

module SecurityApp
  class ProgramFunctionInteractor < BaseInteractor
    def repo
      @repo ||= MenuRepo.new
    end

    def program_function(cached = true)
      if cached
        @program_function ||= repo.find_program_function(@id)
      else
        @program_function = repo.find_program_function(@id)
      end
    end

    def validate_program_function_params(params)
      ProgramFunctionSchema.call(params)
    end

    def create_program_function(params)
      res = validate_program_function_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      @id = repo.create_program_function(res)
      success_response("Created program function #{program_function.program_function_name}",
                       program_function)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { code: ['This program function already exists'] }))
    end

    def update_program_function(id, params)
      @id = id
      res = validate_program_function_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      repo.update_program_function(id, res)
      success_response("Updated program function #{program_function.program_function_name}",
                       program_function(false))
    end

    def delete_program_function(id)
      @id = id
      name = program_function.program_function_name
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
