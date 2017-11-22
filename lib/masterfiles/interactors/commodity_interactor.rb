# frozen_string_literal: true

class CommodityInteractor < BaseInteractor
  def create_commodity_group(params)
    res = validate_commodity_group_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    @commodity_group_id = commodity_repo.create_commodity_group(res.to_h)
    success_response("Created commodity group #{commodity_group.code}", commodity_group)
  end

  def update_commodity_group(id, params)
    @commodity_group_id = id
    res = validate_commodity_group_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    commodity_repo.update_commodity_group(id, res.to_h)
    success_response("Updated commodity group #{commodity_group.code}", commodity_group(false))
  end

  def delete_commodity_group(id)
    @commodity_group_id = id
    name = commodity_group.code
    commodity_repo.delete_commodity_group(id)
    success_response("Deleted commodity group #{name}")
  end

  def create_commodity(params)
    res = validate_commodity_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    @commodity_id = commodity_repo.create_commodity(res.to_h)
    success_response("Created commodity #{commodity.code}", commodity)
  end

  def update_commodity(id, params)
    @commodity_id = id
    res = validate_commodity_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    commodity_repo.update_commodity(id, res.to_h)
    success_response("Updated commodity #{commodity.code}", commodity(false))
  end

  def delete_commodity(id)
    @commodity_id = id
    name = commodity.code
    commodity_repo.delete_commodity(id)
    success_response("Deleted commodity #{name}")
  end

  private

  def commodity_repo
    @commodity_repo ||= CommodityRepo.new
  end

  def commodity_group(cached = true)
    if cached
      @commodity_group ||= commodity_repo.find_commodity_group(@commodity_group_id)
    else
      @commodity_group = commodity_repo.find_commodity_group(@commodity_group_id)
    end
  end

  def validate_commodity_group_params(params)
    CommodityGroupSchema.call(params)
  end

  def commodity(cached = true)
    if cached
      @commodity ||= commodity_repo.find_commodity(@commodity_id)
    else
      @commodity = commodity_repo.find_commodity(@commodity_id)
    end
  end

  def validate_commodity_params(params)
    CommoditySchema.call(params)
  end

end
