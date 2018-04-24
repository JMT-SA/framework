# frozen_string_literal: true

module MasterfilesApp
  class DestinationInteractor < BaseInteractor
    def create_region(params)
      res = validate_region_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      DB.transaction do
        @region_id = destination_repo.create_region(res)
      end
      success_response("Created destination region #{region.destination_region_name}",
                       region)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { destination_region_name: ['This destination region already exists'] }))
    end

    def update_region(id, params)
      @region_id = id
      res = validate_region_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      DB.transaction do
        destination_repo.update_region(id, res)
      end
      success_response("Updated destination region #{region.destination_region_name}",
                       region(false))
    end

    def delete_region(id)
      @region_id = id
      name = region.destination_region_name
      DB.transaction do
        destination_repo.delete_region(id)
      end
      success_response("Deleted destination region #{name}")
    end

    def create_country(params)
      res = validate_country_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      DB.transaction do
        @country_id = destination_repo.create_country(res)
      end
      success_response("Created destination country #{country.country_name}", country)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { country_name: ['This destination country already exists'] }))
    end

    def update_country(id, params)
      @country_id = id
      res = validate_country_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      DB.transaction do
        destination_repo.update_country(id, res)
      end
      success_response("Updated destination country #{country.country_name}", country(false))
    end

    def delete_country(id)
      @country_id = id
      name = country.country_name
      DB.transaction do
        destination_repo.delete_country(id)
      end
      success_response("Deleted destination country #{name}")
    end

    def create_city(params)
      res = validate_city_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      DB.transaction do
        @city_id = destination_repo.create_city(res)
      end
      success_response("Created destination city #{city.city_name}", city)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { city_name: ['This destination city already exists'] }))
    end

    def update_city(id, params)
      @city_id = id
      res = validate_city_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      DB.transaction do
        destination_repo.update_city(id, res)
      end
      success_response("Updated destination city #{city.city_name}", city(false))
    end

    def delete_city(id)
      @city_id = id
      name = city.city_name
      DB.transaction do
        destination_repo.delete_city(id)
      end
      success_response("Deleted destination city #{name}")
    end

    private

    def destination_repo
      @destination_repo ||= DestinationRepo.new
    end

    def region(cached = true)
      if cached
        @region ||= destination_repo.find_region(@region_id)
      else
        @region = destination_repo.find_region(@region_id)
      end
    end

    def validate_region_params(params)
      RegionSchema.call(params)
    end

    def country(cached = true)
      if cached
        @country ||= destination_repo.find_country(@country_id)
      else
        @country = destination_repo.find_country(@country_id)
      end
    end

    def validate_country_params(params)
      CountrySchema.call(params)
    end

    def city(cached = true)
      if cached
        @city ||= destination_repo.find_city(@city_id)
      else
        @city = destination_repo.find_city(@city_id)
      end
    end

    def validate_city_params(params)
      CitySchema.call(params)
    end
  end
end
