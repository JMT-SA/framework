# frozen_string_literal: true

class CultivarGroupInteractor < BaseInteractor
  def cultivar_group_repo
    @cultivar_group_repo ||= CultivarGroupRepo.new
  end

  def cultivar_group(cached = true)
    if cached
      @cultivar_group ||= cultivar_group_repo.find(@id)
    else
      @cultivar_group = cultivar_group_repo.find(@id)
    end
  end

  def validate_cultivar_group_params(params)
    CultivarGroupSchema.call(params)
  end

  def create_cultivar_group(params)
    res = validate_cultivar_group_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    # res = validate_cultivar_group... etc.
    @id = cultivar_group_repo.create(res.to_h)
    success_response("Created cultivar group #{cultivar_group.cultivar_group_code}",
                     cultivar_group)
  end

  def update_cultivar_group(id, params)
    @id = id
    res = validate_cultivar_group_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    # res = validate_cultivar_group... etc.
    cultivar_group_repo.update(id, res.to_h)
    success_response("Updated cultivar group #{cultivar_group.cultivar_group_code}",
                     cultivar_group(false))
  end

  def delete_cultivar_group(id)
    @id = id
    name = cultivar_group.cultivar_group_code
    cultivar_group_repo.delete(id)
    success_response("Deleted cultivar group #{name}")
  end
end
