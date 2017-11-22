# frozen_string_literal: true

class DestinationInteractor < BaseInteractor

  def create_region(params)
    res = validate_region_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    @region_id = destination_repo.create_region(res.to_h)
    success_response("Created destination region #{region.destination_region_name}", region)
  end

  def update_region(id, params)
    @region_id = id
    res = validate_region_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    destination_repo.update_region(id, res.to_h)
    success_response("Updated destination region #{region.destination_region_name}", region(false))
  end

  def delete_region(id)
    @region_id = id
    name = region.destination_region_name
    destination_repo.delete_region(id)
    success_response("Deleted destination region #{name}")
  end

  def create_country(params)
    res = validate_country_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    @country_id = destination_repo.create_country(res.to_h)
    success_response("Created destination country #{country.country_name}", country)
  end

  def update_country(id, params)
    @country_id = id
    res = validate_country_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    destination_repo.update_country(id, res.to_h)
    success_response("Updated destination country #{country.country_name}", country(false))
  end

  def delete_country(id)
    @country_id = id
    name = country.country_name
    destination_repo.delete_country(id)
    success_response("Deleted destination country #{name}")
  end

  def create_city(params)
    res = validate_city_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    @city_id = destination_repo.create_city(res.to_h)
    success_response("Created destination city #{city.city_name}", city)
  end

  def update_city(id, params)
    @city_id = id
    res = validate_city_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    destination_repo.update_city(id, res.to_h)
    success_response("Updated destination city #{city.city_name}", city(false))
  end

  def delete_city(id)
    @city_id = id
    name = city.city_name
    destination_repo.delete_city(id)
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
    DestinationRegionSchema.call(params)
  end

  def country(cached = true)
    if cached
      @country ||= destination_repo.find_country(@country_id)
    else
      @country = destination_repo.find_country(@country_id)
    end
  end

  def validate_country_params(params)
    DestinationCountrySchema.call(params)
  end

  def city(cached = true)
    if cached
      @city ||= destination_repo.find_city(@city_id)
    else
      @city = destination_repo.find_city(@city_id)
    end
  end

  def validate_city_params(params)
    DestinationCitySchema.call(params)
  end

end
