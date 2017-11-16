# frozen_string_literal: true

class StandardPackCodeInteractor < BaseInteractor
  def standard_pack_code_repo
    @standard_pack_code_repo ||= StandardPackCodeRepo.new
  end

  def standard_pack_code(cached = true)
    if cached
      @standard_pack_code ||= standard_pack_code_repo.find(@id)
    else
      @standard_pack_code = standard_pack_code_repo.find(@id)
    end
  end

  def validate_standard_pack_code_params(params)
    StandardPackCodeSchema.call(params)
  end

  def create_standard_pack_code(params)
    res = validate_standard_pack_code_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    # res = validate_standard_pack_code... etc.
    @id = standard_pack_code_repo.create(res.to_h)
    success_response("Created standard pack code #{standard_pack_code.standard_pack_code}",
                     standard_pack_code)
  end

  def update_standard_pack_code(id, params)
    @id = id
    res = validate_standard_pack_code_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    # res = validate_standard_pack_code... etc.
    standard_pack_code_repo.update(id, res.to_h)
    success_response("Updated standard pack code #{standard_pack_code.standard_pack_code}",
                     standard_pack_code(false))
  end

  def delete_standard_pack_code(id)
    @id = id
    name = standard_pack_code.standard_pack_code
    standard_pack_code_repo.delete(id)
    success_response("Deleted standard pack code #{name}")
  end
end
