# frozen_string_literal: true

module MasterfilesApp
  class DestinationRepo < BaseRepo
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

    def delete_region(id) # rubocop:disable Metrics/AbcSize
      countries = DB[:destination_countries].where(destination_region_id: id)
      country_ids = countries.select_map(:id).sort
      dependents = DB[:target_markets_for_countries].where(destination_country_id: country_ids).select_map(:id)
      return { error: 'Some countries are associated to Target Markets' } unless dependents.empty?

      DB[:destination_cities].where(destination_country_id: country_ids).delete
      countries.delete
      DB[:destination_regions].where(id: id).delete
      { success: true }
    end

    def find_country(id)
      hash = find_hash(:destination_countries, id)
      return nil if hash.nil?

      region_hash = where_hash(:destination_regions, id: hash[:destination_region_id])
      hash[:region_name] = region_hash[:destination_region_name] if region_hash

      Country.new(hash)
    end

    def delete_country(id)
      dependents = DB[:target_markets_for_countries].where(destination_country_id: id).select_map(:id)
      return { error: 'This country is associated to Target Markets' } unless dependents.empty?

      DB[:destination_cities].where(destination_country_id: id).delete
      DB[:destination_countries].where(id: id).delete
      { success: true }
    end

    def create_country(id, attrs)
      DB[:destination_countries].insert(attrs.to_h.merge(destination_region_id: id))
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

    def create_city(id, attrs)
      DB[:destination_cities].insert(attrs.to_h.merge(destination_country_id: id))
    end
  end
end
