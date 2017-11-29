# frozen_string_literal: true

class ProgramFunctionInteractor < BaseInteractor
  def repo
    @repo ||= ProgramFunctionRepo.new
  end

  def program_function(cached = true)
    if cached
      @program_function ||= repo.find(:program_functions, ProgramFunction, @id)
    else
      @program_function = repo.find(:program_functions, ProgramFunction, @id)
    end
  end

  def validate_program_function_params(params)
    ProgramFunctionSchema.call(params)
  end

  def create_program_function(params)
    res = validate_program_function_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    @id = repo.create(:program_functions, res.to_h)
    success_response("Created program function #{program_function.program_function_name}",
                     program_function)
  end

  def update_program_function(id, params)
    @id = id
    res = validate_program_function_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    repo.update(:program_functions, id, res.to_h)
    success_response("Updated program function #{program_function.program_function_name}",
                     program_function(false))
  end

  def delete_program_function(id)
    @id = id
    name = program_function.program_function_name
    repo.delete(:program_functions, id)
    success_response("Deleted program function #{name}")
  end

  def link_user(program_function_id, user_ids)
    repo.link_users(program_function_id, user_ids)
    success_response('Linked users to program function')
  end
end
