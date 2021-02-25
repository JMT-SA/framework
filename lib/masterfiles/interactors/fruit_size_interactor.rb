# frozen_string_literal: true

module MasterfilesApp
  class FruitSizeInteractor < BaseInteractor
    def create_std_fruit_size_count(params)
      res = validate_std_fruit_size_count_params(params)
      return validation_failed_response(res) if res.failure?

      id = repo.create_std_fruit_size_count(res)
      instance = std_fruit_size_count(id)
      success_response("Created std fruit size count #{instance.size_count_description}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { size_count_description: ['This std fruit size count already exists'] }))
    end

    def update_std_fruit_size_count(id, params)
      res = validate_std_fruit_size_count_params(params)
      return validation_failed_response(res) if res.failure?

      repo.update_std_fruit_size_count(id, res)
      instance = std_fruit_size_count(id)
      success_response("Updated std fruit size count #{instance.size_count_description}", instance)
    end

    def delete_std_fruit_size_count(id)
      name = std_fruit_size_count(id).size_count_description
      repo.delete_std_fruit_size_count(id)
      success_response("Deleted std fruit size count #{name}")
    end

    def create_fruit_actual_counts_for_pack(parent_id, params)
      params[:std_fruit_size_count_id] = parent_id
      res = validate_fruit_actual_counts_for_pack_params(params)
      return validation_failed_response(res) if res.failure?

      id = repo.create_fruit_actual_counts_for_pack(res)
      instance = fruit_actual_counts_for_pack(id)
      success_response("Created fruit actual counts for pack #{instance.size_count_variation}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { size_count_variation: ['This fruit actual counts for pack already exists'] }))
    end

    def update_fruit_actual_counts_for_pack(id, params)
      res = validate_fruit_actual_counts_for_pack_params(params)
      return validation_failed_response(res) if res.failure?

      instance = fruit_actual_counts_for_pack(id)
      repo.update_fruit_actual_counts_for_pack(id, res)
      success_response("Updated fruit actual counts for pack #{instance.size_count_variation}", instance)
    end

    def delete_fruit_actual_counts_for_pack(id)
      name = fruit_actual_counts_for_pack(id).size_count_variation
      repo.delete_fruit_actual_counts_for_pack(id)
      success_response("Deleted fruit actual counts for pack #{name}")
    end

    def create_fruit_size_reference(parent_id, params)
      params[:fruit_actual_counts_for_pack_id] = parent_id
      res = validate_fruit_size_reference_params(params)
      return validation_failed_response(res) if res.failure?

      id = repo.create_fruit_size_reference(res)
      instance = fruit_size_reference(id)
      success_response("Created fruit size reference #{instance.size_reference}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { size_reference: ['This fruit size reference already exists'] }))
    end

    def update_fruit_size_reference(id, params)
      res = validate_fruit_size_reference_params(params)
      return validation_failed_response(res) if res.failure?

      repo.update_fruit_size_reference(id, res)
      instance = fruit_size_reference(id)
      success_response("Updated fruit size reference #{instance.size_reference}", instance)
    end

    def delete_fruit_size_reference(id)
      name = fruit_size_reference(id).size_reference
      repo.delete_fruit_size_reference(id)
      success_response("Deleted fruit size reference #{name}")
    end

    def assert_permission!(task, id = nil)
      res = TaskPermissionCheck::FruitSizeReference.call(task, id)
      raise Crossbeams::TaskNotPermittedError, res.message unless res.success
    end

    private

    def repo
      @repo ||= FruitSizeRepo.new
    end

    def std_fruit_size_count(id)
      repo.find_std_fruit_size_count(id)
    end

    def validate_std_fruit_size_count_params(params)
      StdFruitSizeCountSchema.call(params)
    end

    def fruit_actual_counts_for_pack(id)
      repo.find_fruit_actual_counts_for_pack(id)
    end

    def validate_fruit_actual_counts_for_pack_params(params)
      FruitActualCountsForPackSchema.call(params)
    end

    def fruit_size_reference(id)
      repo.find_fruit_size_reference(id)
    end

    def validate_fruit_size_reference_params(params)
      FruitSizeReferenceSchema.call(params)
    end
  end
end
