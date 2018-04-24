# frozen_string_literal: true

module MasterfilesApp
  class DestinationRepo < RepoBase
    build_for_select :destination_regions,
                     label: :destination_region_name,
                     value: :id,
                     order_by: :destination_region_name
    build_inactive_select :destination_regions,
                          label: :destination_region_name,
                          value: :id,
                          order_by: :destination_region_name
    build_for_select :destination_countries,
                     label: :country_name,
                     value: :id,
                     order_by: :country_name
    build_inactive_select :destination_countries,
                          label: :country_name,
                          value: :id,
                          order_by: :country_name
    build_for_select :destination_cities,
                     label: :city_name,
                     value: :id,
                     order_by: :city_name
    build_inactive_select :destination_cities,
                          label: :city_name,
                          value: :id,
                          order_by: :city_name

    crud_calls_for :destination_regions, name: :region, wrapper: Region
    crud_calls_for :destination_countries, name: :country, wrapper: Country
    crud_calls_for :destination_cities, name: :city, wrapper: City

    def find_country(id)
      hash = find_hash(:destination_countries, id)
      return nil if hash.nil?

      region_hash = where_hash(:destination_regions, id: hash[:destination_region_id])
      hash[:region_name] = region_hash[:destination_region_name] if region_hash

      Country.new(hash)
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

      City.new(hash)
    end
  end
end
