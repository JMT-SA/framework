# frozen_string_literal: true

class TargetMarketGroupTypeInteractor < BaseInteractor
  def target_market_group_type_repo
    @target_market_group_type_repo ||= TargetMarketGroupTypeRepo.new
  end

  def target_market_group_type(cached = true)
    if cached
      @target_market_group_type ||= target_market_group_type_repo.find(@id)
    else
      @target_market_group_type = target_market_group_type_repo.find(@id)
    end
  end

  def validate_target_market_group_type_params(params)
    TargetMarketGroupTypeSchema.call(params)
  end

  def create_target_market_group_type(params)
    res = validate_target_market_group_type_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    # res = validate_target_market_group_type... etc.
    @id = target_market_group_type_repo.create(res.to_h)
    success_response("Created target market group type #{target_market_group_type.target_market_group_type_code}",
                     target_market_group_type)
  end

  def update_target_market_group_type(id, params)
    @id = id
    res = validate_target_market_group_type_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    # res = validate_target_market_group_type... etc.
    target_market_group_type_repo.update(id, res.to_h)
    success_response("Updated target market group type #{target_market_group_type.target_market_group_type_code}",
                     target_market_group_type(false))
  end

  def delete_target_market_group_type(id)
    @id = id
    name = target_market_group_type.target_market_group_type_code
    target_market_group_type_repo.delete(id)
    success_response("Deleted target market group type #{name}")
  end
end
