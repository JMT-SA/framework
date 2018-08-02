# frozen_string_literal: true

module MasterfilesApp
  class FruitSizeInteractor < BaseInteractor
    def create_std_fruit_size_count(params)
      res = validate_std_fruit_size_count_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      @id = fruit_size_repo.create_std_fruit_size_count(res)
      success_response("Created std fruit size count #{std_fruit_size_count.size_count_description}", std_fruit_size_count)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { size_count_description: ['This std fruit size count already exists'] }))
    end

    def update_std_fruit_size_count(id, params)
      @id = id
      res = validate_std_fruit_size_count_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      fruit_size_repo.update_std_fruit_size_count(id, res)
      success_response("Updated std fruit size count #{std_fruit_size_count.size_count_description}", std_fruit_size_count(false))
    end

    def delete_std_fruit_size_count(id)
      @id = id
      name = std_fruit_size_count.size_count_description
      fruit_size_repo.delete_std_fruit_size_count(id)
      success_response("Deleted std fruit size count #{name}")
    end

    def create_fruit_actual_counts_for_pack(parent_id, params)
      params[:std_fruit_size_count_id] = parent_id
      res = validate_fruit_actual_counts_for_pack_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      @id = fruit_size_repo.create_fruit_actual_counts_for_pack(res)
      success_response("Created fruit actual counts for pack #{fruit_actual_counts_for_pack.size_count_variation}", fruit_actual_counts_for_pack)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { size_count_variation: ['This fruit actual counts for pack already exists'] }))
    end

    def update_fruit_actual_counts_for_pack(id, params)
      @id = id
      res = validate_fruit_actual_counts_for_pack_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      fruit_size_repo.update_fruit_actual_counts_for_pack(id, res)
      success_response("Updated fruit actual counts for pack #{fruit_actual_counts_for_pack.size_count_variation}", fruit_actual_counts_for_pack(false))
    end

    def delete_fruit_actual_counts_for_pack(id)
      @id = id
      name = fruit_actual_counts_for_pack.size_count_variation
      fruit_size_repo.delete_fruit_actual_counts_for_pack(id)
      success_response("Deleted fruit actual counts for pack #{name}")
    end

    def create_fruit_size_reference(parent_id, params)
      params[:fruit_actual_counts_for_pack_id] = parent_id
      res = validate_fruit_size_reference_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      @id = fruit_size_repo.create_fruit_size_reference(res)
      success_response("Created fruit size reference #{fruit_size_reference.size_reference}", fruit_size_reference)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { size_reference: ['This fruit size reference already exists'] }))
    end

    def update_fruit_size_reference(id, params)
      @id = id
      res = validate_fruit_size_reference_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      fruit_size_repo.update_fruit_size_reference(id, res)
      success_response("Updated fruit size reference #{fruit_size_reference.size_reference}", fruit_size_reference(false))
    end

    def delete_fruit_size_reference(id)
      @id = id
      name = fruit_size_reference.size_reference
      fruit_size_repo.delete_fruit_size_reference(id)
      success_response("Deleted fruit size reference #{name}")
    end

    private

    def fruit_size_repo
      @fruit_size_repo ||= FruitSizeRepo.new
    end

    def std_fruit_size_count(cached = true)
      if cached
        @std_fruit_size_count ||= fruit_size_repo.find_std_fruit_size_count(@id)
      else
        @std_fruit_size_count = fruit_size_repo.find_std_fruit_size_count(@id)
      end
    end

    def validate_std_fruit_size_count_params(params)
      StdFruitSizeCountSchema.call(params)
    end

    def fruit_actual_counts_for_pack(cached = true)
      if cached
        @fruit_actual_counts_for_pack ||= fruit_size_repo.find_fruit_actual_counts_for_pack(@id)
      else
        @fruit_actual_counts_for_pack = fruit_size_repo.find_fruit_actual_counts_for_pack(@id)
      end
    end

    def validate_fruit_actual_counts_for_pack_params(params)
      FruitActualCountsForPackSchema.call(params)
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
  end
end
