# frozen_string_literal: true

class BasicPackCodeInteractor < BaseInteractor
  def basic_pack_code_repo
    @basic_pack_code_repo ||= BasicPackCodeRepo.new
  end

  def basic_pack_code(cached = true)
    if cached
      @basic_pack_code ||= basic_pack_code_repo.find(@id)
    else
      @basic_pack_code = basic_pack_code_repo.find(@id)
    end
  end

  def validate_basic_pack_code_params(params)
    BasicPackCodeSchema.call(params)
  end

  def create_basic_pack_code(params)
    res = validate_basic_pack_code_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    # res = validate_basic_pack_code... etc.
    @id = basic_pack_code_repo.create(res.to_h)
    success_response("Created basic pack code #{basic_pack_code.basic_pack_code}",
                     basic_pack_code)
  end

  def update_basic_pack_code(id, params)
    @id = id
    res = validate_basic_pack_code_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    # res = validate_basic_pack_code... etc.
    basic_pack_code_repo.update(id, res.to_h)
    success_response("Updated basic pack code #{basic_pack_code.basic_pack_code}",
                     basic_pack_code(false))
  end

  def delete_basic_pack_code(id)
    @id = id
    name = basic_pack_code.basic_pack_code
    basic_pack_code_repo.delete(id)
    success_response("Deleted basic pack code #{name}")
  end
end
