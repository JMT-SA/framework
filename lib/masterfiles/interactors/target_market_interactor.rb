# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize

module MasterfilesApp
  class TargetMarketInteractor < BaseInteractor
    def create_tm_group_type(params)
      res = validate_tm_group_type_params(params)
      return validation_failed_response(res) if res.failure?

      id = nil
      repo.transaction do
        id = repo.create_tm_group_type(res)
      end
      instance = tm_group_type(id)
      success_response("Created target market group type #{instance.target_market_group_type_code}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { target_market_group_type_code: ['This target market group type already exists'] }))
    end

    def update_tm_group_type(id, params)
      res = validate_tm_group_type_params(params)
      return validation_failed_response(res) if res.failure?

      repo.transaction do
        repo.update_tm_group_type(id, res)
      end
      instance = tm_group_type(id)
      success_response("Updated target market group type #{instance.target_market_group_type_code}",
                       instance)
    end

    def delete_tm_group_type(id)
      name = tm_group_type(id).target_market_group_type_code
      repo.transaction do
        repo.delete_tm_group_type(id)
      end
      success_response("Deleted target market group type #{name}")
    end

    def create_tm_group(params)
      res = validate_tm_group_params(params)
      return validation_failed_response(res) if res.failure?

      id = nil
      repo.transaction do
        id = repo.create_tm_group(res)
      end
      instance = tm_group(id)
      success_response("Created target market group #{instance.target_market_group_name}",
                       instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { target_market_group_name: ['This target market group already exists'] }))
    end

    def update_tm_group(id, params)
      res = validate_tm_group_params(params)
      return validation_failed_response(res) if res.failure?

      repo.transaction do
        repo.update_tm_group(id, res)
      end
      instance = tm_group(id)
      success_response("Updated target market group #{instance.target_market_group_name}", instance)
    end

    def delete_tm_group(id)
      name = tm_group(id).target_market_group_name
      repo.transaction do
        repo.delete_tm_group(id)
      end
      success_response("Deleted target market group #{name}")
    end

    def create_target_market(params)
      res = validate_target_market_params(params)
      return validation_failed_response(res) if res.failure?

      res = res.to_h
      country_ids = res.delete(:country_ids)
      tm_group_ids = res.delete(:tm_group_ids)

      id = nil
      repo.transaction do
        id = repo.create_target_market(res)
      end
      country_response = link_countries(id, country_ids)
      tm_groups_response = link_tm_groups(id, tm_group_ids)
      instance = target_market(id)
      success_response("Created target market #{instance.target_market_name}, #{country_response.message}, #{tm_groups_response.message}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { target_market_name: ['This target market already exists'] }))
    end

    def update_target_market(id, params)
      res = validate_target_market_params(params)
      return validation_failed_response(res) if res.failure?

      res = res.to_h
      country_ids = res.delete(:country_ids)
      tm_group_ids = res.delete(:tm_group_ids)

      country_response = link_countries(id, country_ids)
      tm_groups_response = link_tm_groups(id, tm_group_ids)
      repo.update_target_market(id, res)
      instance = target_market(id)
      success_response("Updated target market #{instance.target_market_name}, #{country_response.message}, #{tm_groups_response.message}", instance)
    end

    def delete_target_market(id)
      name = target_market(id).target_market_name
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
      @repo ||= TargetMarketRepo.new
    end

    def tm_group_type(id)
      repo.find_tm_group_type(id)
    end

    def validate_tm_group_type_params(params)
      TmGroupTypeSchema.call(params)
    end

    def tm_group(id)
      repo.find_tm_group(id)
    end

    def validate_tm_group_params(params)
      TmGroupSchema.call(params)
    end

    def target_market(id)
      repo.find_target_market(id)
    end

    def validate_target_market_params(params)
      TargetMarketSchema.call(params)
    end
  end
end
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/AbcSize
