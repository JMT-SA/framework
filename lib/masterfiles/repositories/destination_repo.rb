# frozen_string_literal: true

class DestinationRepo < RepoBase

  def create_region(attrs)
    DB[:destination_regions].insert(attrs.to_h)
  end

  def find_region(id)
    hash = DB[:destination_regions].where(id: id).first
    return nil if hash.nil?
    DestinationRegion.new(hash)
  end

  def update_region(id, attrs)
    DB[:destination_regions].where(id: id).update(attrs.to_h)
  end

  def delete_region(id)
    DB[:destination_regions].where(id: id).delete
  end

  def create_country(attrs)
    DB[:destination_countries].insert(attrs.to_h)
  end

  def find_country(id)
    hash = DB[:destination_countries].where(id: id).first
    return nil if hash.nil?

    region_hash = DB[:destination_regions].where(id: hash[:destination_region_id]).first
    hash.merge!(region_name: region_hash[:destination_region_name]) if region_hash

    DestinationCountry.new(hash)
  end

  def update_country(id, attrs)
    DB[:destination_countries].where(id: id).update(attrs.to_h)
  end

  def delete_country(id)
    DB[:destination_countries].where(id: id).delete
  end

  def create_city(attrs)
    # DestinationCityRepo.new.create(attrs)
    # self.set_for_cities
    # self.create(attrs)
    DB[:destination_cities].insert(attrs.to_h)
  end

  def find_city(id)
    hash = DB[:destination_cities].where(id: id).first
    return nil if hash.nil?

    country_hash = DB[:destination_countries].where(id: hash[:destination_country_id]).first
    if country_hash
      region_hash = DB[:destination_regions].where(id: country_hash[:destination_region_id]).first
      hash.merge!(country_name: country_hash[:country_name]) if country_hash
      hash.merge!(region_name: region_hash[:destination_region_name]) if region_hash
    end

    DestinationCity.new(hash)
  end

  def update_city(id, attrs)
    DB[:destination_cities].where(id: id).update(attrs.to_h)
  end

  def delete_city(id)
    DB[:destination_cities].where(id: id).delete
  end

  def regions_for_select
    self.set_for_regions
    self.for_select
  end

  def countries_for_select
    self.set_for_countries
    self.for_select
  end

  def set_for_regions
    @main_table_name = :destination_regions
    @wrapper = DestinationRegion
    @select_options = {
      label: :destination_region_name,
      value: :id,
      order_by: :destination_region_name
    }
  end

  def set_for_countries
    @main_table_name = :destination_countries
    @wrapper = DestinationCountry
    @select_options = {
      label: :country_name,
      value: :id,
      order_by: :country_name
    }
  end

  def set_for_cities
    @main_table_name = :destination_cities
    @wrapper = DestinationCity
    @select_options = {
      label: :city_name,
      value: :id,
      order_by: :city_name
    }
  end

end