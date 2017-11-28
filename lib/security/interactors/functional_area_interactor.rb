# frozen_string_literal: true

class FunctionalAreaInteractor < BaseInteractor
  def repo
    @repo ||= FunctionalAreaRepo.new
  end

  def functional_area(cached = true)
    if cached
      @functional_area ||= repo.find(:functional_areas, FunctionalArea, @id)
    else
      @functional_area = repo.find(:functional_areas, FunctionalArea, @id)
    end
  end

  def validate_functional_area_params(params)
    FunctionalAreaSchema.call(params)
  end

  def create_functional_area(params)
    res = validate_functional_area_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    @id = repo.create(:functional_areas, res.to_h)
    success_response("Created functional area #{functional_area.functional_area_name}",
                     functional_area)
  end

  def update_functional_area(id, params)
    @id = id
    res = validate_functional_area_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    repo.update(:functional_areas, id, res.to_h)
    success_response("Updated functional area #{functional_area.functional_area_name}",
                     functional_area(false))
  end

  def delete_functional_area(id)
    @id = id
    name = functional_area.functional_area_name
    repo.delete(:functional_areas, id)
    success_response("Deleted functional area #{name}")
  end
end
