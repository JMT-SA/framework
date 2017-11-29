# frozen_string_literal: true

class DestinationRepo < RepoBase
  build_for_select :destination_regions,
                   label: :destination_region_name,
                   value: :id,
                   order_by: :destination_region_name

  build_for_select :destination_countries,
                   label: :country_name,
                   value: :id,
                   order_by: :country_name

  build_for_select :destination_cities,
                   label: :city_name,
                   value: :id,
                   order_by: :city_name

  def create_region(attrs)
    create(:destination_regions, attrs)
  end

  def find_region(id)
    find(:destination_regions, DestinationRegion, id)
  end

  def update_region(id, attrs)
    update(:destination_regions, id, attrs)
  end

  def delete_region(id)
    delete(:destination_regions, id)
  end

  def create_country(attrs)
    create(:destination_countries, attrs)
  end

  def find_country(id)
    hash = find_hash(:destination_countries, id)
    return nil if hash.nil?

    region_hash = where_hash(:destination_regions, id: hash[:destination_region_id])
    hash[:region_name] = region_hash[:destination_region_name] if region_hash

    DestinationCountry.new(hash)
  end

  def update_country(id, attrs)
    update(:destination_countries, id, attrs)
  end

  def delete_country(id)
    delete(:destination_countries, id)
  end

  def create_city(attrs)
    create(:destination_cities, attrs)
  end

  def find_city(id)
    hash = find_hash(:destination_cities, id)
    return nil if hash.nil?

    country_hash = where_hash(:destination_countries, id: hash[:destination_country_id])
    if country_hash
      region_hash = where_hash(:destination_regions, id: country_hash[:destination_region_id])
      hash[:country_name] = country_hash[:country_name] if country_hash
      hash[:region_name] = region_hash[:destination_region_name] if region_hash
    end

    DestinationCity.new(hash)
  end

  def update_city(id, attrs)
    update(:destination_cities, id, attrs)
  end

  def delete_city(id)
    delete(:destination_cities, id)
  end
end
