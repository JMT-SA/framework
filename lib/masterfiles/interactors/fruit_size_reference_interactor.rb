# frozen_string_literal: true

module MasterfilesApp
  class FruitSizeReferenceInteractor < BaseInteractor
    def fruit_size_repo
      @fruit_size_repo ||= FruitSizeRepo.new
    end

    def fruit_size_reference(cached = true)
      if cached
        @fruit_size_reference ||= fruit_size_repo.find_fruit_size_reference(@id)
      else
        @fruit_size_reference = fruit_size_repo.find_fruit_size_reference(@id)
      end
    end

    def validate_fruit_size_reference_params(params)
      FruitSizeReferenceSchema.call(params)
    end

    def create_fruit_size_reference(parent_id, params)
      params[:fruit_actual_counts_for_pack_id] = parent_id
      res = validate_fruit_size_reference_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      @id = fruit_size_repo.create_fruit_size_reference(res.to_h)
      success_response("Created fruit size reference #{fruit_size_reference.size_reference}",
                       fruit_size_reference)
    end

    def update_fruit_size_reference(id, params)
      @id = id
      res = validate_fruit_size_reference_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      fruit_size_repo.update_fruit_size_reference(id, res.to_h)
      success_response("Updated fruit size reference #{fruit_size_reference.size_reference}",
                       fruit_size_reference(false))
    end

    def delete_fruit_size_reference(id)
      @id = id
      name = fruit_size_reference.size_reference
      fruit_size_repo.delete_fruit_size_reference(id)
      success_response("Deleted fruit size reference #{name}")
    end
  end
end
