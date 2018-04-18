# frozen_string_literal: true

module MasterfilesApp
  class StdFruitSizeCountInteractor < BaseInteractor
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

    def create_std_fruit_size_count(params)
      res = validate_std_fruit_size_count_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      @id = fruit_size_repo.create_std_fruit_size_count(res.to_h)
      success_response("Created std fruit size count #{std_fruit_size_count.size_count_description}", std_fruit_size_count)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { size_count_description: ['This std fruit size count already exists'] }))
    end

    def update_std_fruit_size_count(id, params)
      @id = id
      res = validate_std_fruit_size_count_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      fruit_size_repo.update_std_fruit_size_count(id, res.to_h)
      success_response("Updated std fruit size count #{std_fruit_size_count.size_count_description}", std_fruit_size_count(false))
    end

    def delete_std_fruit_size_count(id)
      @id = id
      name = std_fruit_size_count.size_count_description
      fruit_size_repo.delete_std_fruit_size_count(id)
      success_response("Deleted std fruit size count #{name}")
    end
  end
end
