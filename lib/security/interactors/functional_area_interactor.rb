# frozen_string_literal: true

module SecurityApp
  class FunctionalAreaInteractor < BaseInteractor
    def repo
      @repo ||= MenuRepo.new
    end

    def functional_area(id)
      repo.find_functional_area(id)
    end

    def validate_functional_area_params(params)
      FunctionalAreaSchema.call(params)
    end

    def create_functional_area(params)
      res = validate_functional_area_params(params)
      return validation_failed_response(res) if res.failure?

      id = repo.create_functional_area(res)
      instance = functional_area(id)
      success_response("Created functional area #{instance.functional_area_name}",
                       instance)
    end

    def update_functional_area(id, params)
      res = validate_functional_area_params(params)
      return validation_failed_response(res) if res.failure?

      repo.update_functional_area(id, res)
      instance = functional_area(id)
      success_response("Updated functional area #{instance.functional_area_name}",
                       instance)
    end

    def delete_functional_area(id)
      name = functional_area(id).functional_area_name
      repo.delete_functional_area(id)
      success_response("Deleted functional area #{name}")
    end

    def reorder_programs(params)
      repo.re_order_programs(params)
      success_response('Re-ordered programs')
    end

    def show_sql(id, webapp)
      DataToSql.new(webapp).sql_for(:functional_areas, id)
    end
  end
end
