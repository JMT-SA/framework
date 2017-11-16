# frozen_string_literal: true

class TargetMarketGroupInteractor < BaseInteractor
  def target_market_group_repo
    @target_market_group_repo ||= TargetMarketGroupRepo.new
  end

  def target_market_group(cached = true)
    if cached
      @target_market_group ||= target_market_group_repo.find(@id)
    else
      @target_market_group = target_market_group_repo.find(@id)
    end
  end

  def validate_target_market_group_params(params)
    TargetMarketGroupSchema.call(params)
  end

  def create_target_market_group(params)
    res = validate_target_market_group_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    # res = validate_target_market_group... etc.
    @id = target_market_group_repo.create(res.to_h)
    success_response("Created target market group #{target_market_group.target_market_group_name}",
                     target_market_group)
  end

  def update_target_market_group(id, params)
    @id = id
    res = validate_target_market_group_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    # res = validate_target_market_group... etc.
    target_market_group_repo.update(id, res.to_h)
    success_response("Updated target market group #{target_market_group.target_market_group_name}",
                     target_market_group(false))
  end

  def delete_target_market_group(id)
    @id = id
    name = target_market_group.target_market_group_name
    target_market_group_repo.delete(id)
    success_response("Deleted target market group #{name}")
  end
end
