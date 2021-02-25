# frozen_string_literal: true

module SecurityApp
  class ProgramInteractor < BaseInteractor
    def repo
      @repo ||= MenuRepo.new
    end

    def program(id)
      repo.find_program(id)
    end

    def validate_program_params(params)
      ProgramSchema.call(params)
    end

    def validate_edit_program_params(params)
      EditProgramSchema.call(params)
    end

    def create_program(params, webapp)
      res = validate_program_params(params)
      return validation_failed_response(res) if res.failure?

      id = repo.create_program(res, webapp)
      instance = program(id)
      success_response("Created program #{instance.program_name}",
                       instance)
    end

    def update_program(id, params)
      res = validate_edit_program_params(params)
      return validation_failed_response(res) if res.failure?

      repo.update_program(id, res)
      instance = program(id)
      success_response("Updated program #{instance.program_name}",
                       instance)
    end

    def delete_program(id)
      name = program(id).program_name
      repo.delete_program(id)
      success_response("Deleted program #{name}")
    end

    def reorder_program_functions(params)
      repo.re_order_program_functions(params)
      success_response('Re-ordered program functions')
    end

    def link_user(user_id, program_ids)
      repo.transaction do
        repo.link_user(user_id, program_ids)
      end
      success_response('Linked programs to user')
    end

    def show_sql(id, webapp)
      DataToSql.new(webapp).sql_for(:programs, id)
    end
  end
end
