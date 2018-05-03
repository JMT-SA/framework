# frozen_string_literal: true

module SecurityApp
  class FunctionalAreaInteractor < BaseInteractor
    def repo
      @repo ||= MenuRepo.new
    end

    def functional_area(cached = true)
      if cached
        @functional_area ||= repo.find_functional_area(@id)
      else
        @functional_area = repo.find_functional_area(@id)
      end
    end

    def validate_functional_area_params(params)
      FunctionalAreaSchema.call(params)
    end

    def create_functional_area(params)
      res = validate_functional_area_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      @id = repo.create_functional_area(res)
      success_response("Created functional area #{functional_area.functional_area_name}",
                       functional_area)
    end

    def update_functional_area(id, params)
      @id = id
      res = validate_functional_area_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      repo.update_functional_area(id, res)
      success_response("Updated functional area #{functional_area.functional_area_name}",
                       functional_area(false))
    end

    def delete_functional_area(id)
      @id = id
      name = functional_area.functional_area_name
      repo.delete_functional_area(id)
      success_response("Deleted functional area #{name}")
    end
  end
end
