# frozen_string_literal: true

class StdFruitSizeCountInteractor < BaseInteractor
  def std_fruit_size_count_repo
    @std_fruit_size_count_repo ||= StdFruitSizeCountRepo.new
  end

  def std_fruit_size_count(cached = true)
    if cached
      @std_fruit_size_count ||= std_fruit_size_count_repo.find(@id)
    else
      @std_fruit_size_count = std_fruit_size_count_repo.find(@id)
    end
  end

  def validate_std_fruit_size_count_params(params)
    StdFruitSizeCountSchema.call(params)
  end

  def create_std_fruit_size_count(params)
    res = validate_std_fruit_size_count_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    # res = validate_std_fruit_size_count... etc.
    @id = std_fruit_size_count_repo.create(res.to_h)
    success_response("Created std fruit size count #{std_fruit_size_count.size_count_description}",
                     std_fruit_size_count)
  end

  def update_std_fruit_size_count(id, params)
    @id = id
    res = validate_std_fruit_size_count_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    # res = validate_std_fruit_size_count... etc.
    std_fruit_size_count_repo.update(id, res.to_h)
    success_response("Updated std fruit size count #{std_fruit_size_count.size_count_description}",
                     std_fruit_size_count(false))
  end

  def delete_std_fruit_size_count(id)
    @id = id
    name = std_fruit_size_count.size_count_description
    std_fruit_size_count_repo.delete(id)
    success_response("Deleted std fruit size count #{name}")
  end
end
