# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize

module MasterfilesApp
  class TargetMarketInteractor < BaseInteractor
    def create_tm_group_type(params)
      res = validate_tm_group_type_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      repo.transaction do
        @tm_group_type_id = repo.create_tm_group_type(res)
      end
      success_response("Created target market group type #{tm_group_type.target_market_group_type_code}", tm_group_type)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { target_market_group_type_code: ['This target market group type already exists'] }))
    end

    def update_tm_group_type(id, params)
      @tm_group_type_id = id
      res = validate_tm_group_type_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      repo.transaction do
        repo.update_tm_group_type(id, res)
      end
      success_response("Updated target market group type #{tm_group_type.target_market_group_type_code}",
                       tm_group_type(false))
    end

    def delete_tm_group_type(id)
      @tm_group_type_id = id
      name = tm_group_type.target_market_group_type_code
      repo.transaction do
        repo.delete_tm_group_type(id)
      end
      success_response("Deleted target market group type #{name}")
    end

    def create_tm_group(params)
      res = validate_tm_group_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      repo.transaction do
        @tm_group_id = repo.create_tm_group(res)
      end
      success_response("Created target market group #{tm_group.target_market_group_name}",
                       tm_group)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { target_market_group_name: ['This target market group already exists'] }))
    end

    def update_tm_group(id, params)
      @tm_group_id = id
      res = validate_tm_group_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      repo.transaction do
        repo.update_tm_group(id, res)
      end
      success_response("Updated target market group #{tm_group.target_market_group_name}", tm_group(false))
    end

    def delete_tm_group(id)
      @tm_group_id = id
      name = tm_group.target_market_group_name
      repo.transaction do
        repo.delete_tm_group(id)
      end
      success_response("Deleted target market group #{name}")
    end

    def create_target_market(params)
      res = validate_target_market_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      res = res.to_h
      country_ids = res.delete(:country_ids)
      tm_group_ids = res.delete(:tm_group_ids)

      repo.transaction do
        @target_market_id = repo.create_target_market(res)
      end
      country_response = link_countries(@target_market_id, country_ids)
      tm_groups_response = link_tm_groups(@target_market_id, tm_group_ids)
      success_response("Created target market #{target_market.target_market_name}, #{country_response.message}, #{tm_groups_response.message}", target_market)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { target_market_name: ['This target market already exists'] }))
    end

    def update_target_market(id, params)
      @target_market_id = id
      res = validate_target_market_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      res = res.to_h
      country_ids = res.delete(:country_ids)
      tm_group_ids = res.delete(:tm_group_ids)

      country_response = link_countries(@target_market_id, country_ids)
      tm_groups_response = link_tm_groups(@target_market_id, tm_group_ids)
      repo.update_target_market(id, res)
      success_response("Updated target market #{target_market.target_market_name}, #{country_response.message}, #{tm_groups_response.message}", target_market(false))
    end

    def delete_target_market(id)
      @target_market_id = id
      name = target_market.target_market_name
      repo.delete_target_market(id)
      success_response("Deleted target market #{name}")
    end

    def link_countries(target_market_id, country_ids)
      return failed_response('You have not selected any countries') unless country_ids
      repo.transaction do
        repo.link_countries(target_market_id, country_ids)
      end

      existing_ids = repo.target_market_country_ids(target_market_id)
      if existing_ids.eql?(country_ids.sort)
        success_response('Countries linked successfully')
      else
        failed_response('Some countries were not linked')
      end
    end

    def link_tm_groups(target_market_id, tm_group_ids)
      return failed_response('You have not selected any target market groups') unless tm_group_ids
      repo.transaction do
        repo.link_tm_groups(target_market_id, tm_group_ids)
      end

      existing_ids = repo.target_market_tm_group_ids(target_market_id)
      if existing_ids.eql?(tm_group_ids.sort)
        success_response('Target market groups linked successfully')
      else
        failed_response('Some target market groups were not linked')
      end
    end

    private

    def repo
      @target_market_repo ||= TargetMarketRepo.new
    end

    def tm_group_type(cached = true)
      if cached
        @tm_group_type ||= repo.find_tm_group_type(@tm_group_type_id)
      else
        @tm_group_type = repo.find_tm_group_type(@tm_group_type_id)
      end
    end

    def validate_tm_group_type_params(params)
      TmGroupTypeSchema.call(params)
    end

    def tm_group(cached = true)
      if cached
        @tm_group ||= repo.find_tm_group(@tm_group_id)
      else
        @tm_group = repo.find_tm_group(@tm_group_id)
      end
    end

    def validate_tm_group_params(params)
      TmGroupSchema.call(params)
    end

    def target_market(cached = true)
      if cached
        @target_market ||= repo.find_target_market(@target_market_id)
      else
        @target_market = repo.find_target_market(@target_market_id)
      end
    end

    def validate_target_market_params(params)
      TargetMarketSchema.call(params)
    end
  end
end
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/AbcSize
