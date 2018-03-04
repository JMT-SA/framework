# frozen_string_literal: true

class ProgramInteractor < BaseInteractor
  def repo
    @repo ||= ProgramRepo.new
  end

  def program(cached = true)
    if cached
      @program ||= repo.find(:programs, Program, @id)
    else
      @program = repo.find(:programs, Program, @id)
    end
  end

  def validate_program_params(params)
    ProgramSchema.call(params)
  end

  def validate_edit_program_params(params)
    EditProgramSchema.call(params)
  end

  def create_program(params, webapp)
    res = validate_program_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    @id = repo.create_program(res.to_h, webapp)
    success_response("Created program #{program.program_name}",
                     program)
  end

  def update_program(id, params)
    @id = id
    res = validate_edit_program_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    repo.update_program(id, res.to_h)
    success_response("Updated program #{program.program_name}",
                     program(false))
  end

  def delete_program(id)
    @id = id
    name = program.program_name
    repo.delete(:programs, id)
    success_response("Deleted program #{name}")
  end

  def reorder_program_functions(params)
    repo.re_order_program_functions(params)
    success_response('Re-ordered program functions')
  end

  def link_user(user_id, program_ids)
    DB.transaction do
      repo.link_user(user_id, program_ids)
    end
    success_response('Linked programs to user')
  end
end
