# frozen_string_literal: true

class CultivarInteractor < BaseInteractor
  def cultivar_repo
    @cultivar_repo ||= CultivarRepo.new
  end

  def cultivar(cached = true)
    if cached
      @cultivar ||= cultivar_repo.find(@id)
    else
      @cultivar = cultivar_repo.find(@id)
    end
  end

  def validate_cultivar_params(params)
    CultivarSchema.call(params)
  end

  def create_cultivar(params)
    res = validate_cultivar_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    # res = validate_cultivar... etc.
    @id = cultivar_repo.create(res.to_h)
    success_response("Created cultivar #{cultivar.cultivar_name}",
                     cultivar)
  end

  def update_cultivar(id, params)
    @id = id
    res = validate_cultivar_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    # res = validate_cultivar... etc.
    cultivar_repo.update(id, res.to_h)
    success_response("Updated cultivar #{cultivar.cultivar_name}",
                     cultivar(false))
  end

  def delete_cultivar(id)
    @id = id
    name = cultivar.cultivar_name
    cultivar_repo.delete(id)
    success_response("Deleted cultivar #{name}")
  end
end
