# frozen_string_literal: true

module MasterfilesApp
  class CommodityInteractor < BaseInteractor
    def create_commodity_group(params)
      res = validate_commodity_group_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      @commodity_group_id = repo.create_commodity_group(res)
      success_response("Created commodity group #{commodity_group.code}", commodity_group)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { code: ['This commodity group already exists'] }))
    end

    def update_commodity_group(id, params)
      @commodity_group_id = id
      res = validate_commodity_group_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      repo.update_commodity_group(id, res)
      success_response("Updated commodity group #{commodity_group.code}", commodity_group(false))
    end

    def delete_commodity_group(id)
      @commodity_group_id = id
      name = commodity_group.code
      res = {}
      repo.transaction do
        res = repo.delete_commodity_group(id)
      end
      if res[:error]
        failed_response(res[:error])
      else
        success_response("Deleted commodity group #{name}")
      end
    end

    def create_commodity(params)
      res = validate_commodity_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      @commodity_id = repo.create_commodity(res)
      success_response("Created commodity #{commodity.code}", commodity)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { code: ['This commodity already exists'] }))
    end

    def update_commodity(id, params)
      @commodity_id = id
      res = validate_commodity_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      repo.update_commodity(id, res)
      success_response("Updated commodity #{commodity.code}", commodity(false))
    end

    def delete_commodity(id)
      @commodity_id = id
      name = commodity.code
      res = {}
      repo.transaction do
        res = repo.delete_commodity(id)
      end
      if res[:error]
        failed_response(res[:error])
      else
        success_response("Deleted commodity #{name}")
      end
    end

    private

    def repo
      @commodity_repo ||= CommodityRepo.new
    end

    def commodity_group(cached = true)
      if cached
        @commodity_group ||= repo.find_commodity_group(@commodity_group_id)
      else
        @commodity_group = repo.find_commodity_group(@commodity_group_id)
      end
    end

    def validate_commodity_group_params(params)
      CommodityGroupSchema.call(params)
    end

    def commodity(cached = true)
      if cached
        @commodity ||= repo.find_commodity(@commodity_id)
      else
        @commodity = repo.find_commodity(@commodity_id)
      end
    end

    def validate_commodity_params(params)
      CommoditySchema.call(params)
    end
  end
end
