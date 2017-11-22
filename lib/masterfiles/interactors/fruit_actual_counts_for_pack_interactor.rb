# frozen_string_literal: true

class FruitActualCountsForPackInteractor < BaseInteractor
  def fruit_actual_counts_for_pack_repo
    @fruit_actual_counts_for_pack_repo ||= FruitActualCountsForPackRepo.new
  end

  def fruit_actual_counts_for_pack(cached = true)
    if cached
      @fruit_actual_counts_for_pack ||= fruit_actual_counts_for_pack_repo.find(@id)
    else
      @fruit_actual_counts_for_pack = fruit_actual_counts_for_pack_repo.find(@id)
    end
  end

  def validate_fruit_actual_counts_for_pack_params(params)
    FruitActualCountsForPackSchema.call(params)
  end

  def create_fruit_actual_counts_for_pack(parent_id, params)
    params[:std_fruit_size_count_id] = parent_id
    res = validate_fruit_actual_counts_for_pack_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    @id = fruit_actual_counts_for_pack_repo.create(res.to_h)
    success_response("Created fruit actual counts for pack #{fruit_actual_counts_for_pack.size_count_variation}",
                     fruit_actual_counts_for_pack)
  end

  def update_fruit_actual_counts_for_pack(id, params)
    @id = id
    res = validate_fruit_actual_counts_for_pack_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    fruit_actual_counts_for_pack_repo.update(id, res.to_h)
    success_response("Updated fruit actual counts for pack #{fruit_actual_counts_for_pack.size_count_variation}",
                     fruit_actual_counts_for_pack(false))
  end

  def delete_fruit_actual_counts_for_pack(id)
    @id = id
    name = fruit_actual_counts_for_pack.size_count_variation
    fruit_actual_counts_for_pack_repo.delete(id)
    success_response("Deleted fruit actual counts for pack #{name}")
  end
end
