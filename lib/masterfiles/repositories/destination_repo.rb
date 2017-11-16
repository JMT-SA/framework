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
    @main_table_name = :destination_regions
    @select_options = {
      label: :destination_region_name,
      value: :id,
      order_by: :destination_region_name
    }
    self.for_select
  end

  def countries_for_select
    @main_table_name = :destination_countries
    @select_options = {
      label: :country_name,
      value: :id,
      order_by: :country_name
    }
    self.for_select
  end


  # class DestinationCityRepo < RepoBase
  #   def initialize
  #     main_table :destination_cities
  #     table_wrapper DestinationCity
  #     for_select_options label: :city_name,
  #                        value: :id,
  #                        order_by: :city_name
  #   end
  # end

  # class DestinationRegionRepo < RepoBase
  #   def initialize
  #     main_table :destination_regions
  #     table_wrapper DestinationRegion
  #     for_select_options label: :destination_region_name,
  #                        value: :id,
  #                        order_by: :destination_region_name
  #   end
  # end
  #
  #
  # class DestinationCountryRepo < RepoBase
  #   def initialize
  #     main_table :destination_countries
  #     table_wrapper DestinationCountry
  #     for_select_options label: :country_name,
  #                        value: :id,
  #                        order_by: :country_name
  #   end
  # end
  #
  # attr_reader :main_table_name, :wrapper, :select_options
  #
  # def initialize
  #   @main_table_name = nil
  #   @wrapper = nil
  #   @select_options = {}
  # end
  #
  # def main_table(value)
  #   @main_table_name = value
  # end
  #
  # def table_wrapper(value)
  #   @wrapper = value
  # end
  #
  # def for_select_options(value = {})
  #   @select_options = value
  # end
  #
  # def all
  #   raise Crossbeams::FrameworkError, "#{self.class.name}: Cannot call 'all' on a repo that was not initialized with a wrapper. Use a wrapper or 'all_hash'." if wrapper.nil?
  #   all_hash.map { |r| wrapper.new(r) }
  # end
  #
  # def all_hash
  #   DB[main_table_name].all
  # end
  #
  # def find!(id)
  #   raise Crossbeams::FrameworkError, "#{self.class.name}: Cannot call 'find!' on a repo that was not initialized with a wrapper. Use a wrapper or 'find_hash'." if wrapper.nil?
  #   hash = find_hash(id)
  #   raise Crossbeams::FrameworkError, "#{self.class.name}: id #{id} not found." if hash.nil?
  #   wrapper.new(hash)
  # end
  #
  # def find(id)
  #   raise Crossbeams::FrameworkError, "#{self.class.name}: Cannot call 'find' on a repo that was not initialized with a wrapper. Use a wrapper or 'find_hash'." if wrapper.nil?
  #   hash = find_hash(id)
  #   return nil if hash.nil?
  #   wrapper.new(hash)
  # end
  #
  # def find_hash(id)
  #   where_hash(id: id)
  # end
  #
  # def where(args)
  #   raise Crossbeams::FrameworkError, "#{self.class.name}: Cannot call 'where' on a repo that was not initialized with a wrapper. Use a wrapper or 'where_hash'." if wrapper.nil?
  #   hash = where_hash(args)
  #   return nil if hash.nil?
  #   wrapper.new(hash)
  # end
  #
  # def where_hash(args)
  #   DB[main_table_name].where(args).first
  # end
  #
  # def exists?(args)
  #   DB.select(1).where(DB[main_table_name].where(args).exists).one?
  # end
  #
  # def row_exists?(table_name, args)
  #   DB.select(1).where(DB[table_name].where(args).exists).one?
  # end
  #
  # def create(attrs)
  #   DB[main_table_name].insert(attrs.to_h)
  # end
  #
  # def update(id, attrs)
  #   DB[main_table_name].where(id: id).update(attrs.to_h)
  # end
  #
  # def delete(id)
  #   DB[main_table_name].where(id: id).delete
  # end
  #
  # def select_values(query)
  #   DB[query].select_map
  # end
  #
  # # List of rows for use in a select dropdown.
  # # Uses for_select_options to configure.
  # # @return Array - list of label/value pairs or just of values.
  # def for_select
  #   dataset = DB[main_table_name]
  #   dataset = make_order(dataset) if select_options[:order_by]
  #   select_label_name == select_value_name ? select_single(dataset) : select_two(dataset)
  # end
  #
  # def select_single(dataset)
  #   dataset.map { |rec| rec[select_value_name] }
  # end
  #
  # def select_two(dataset)
  #   dataset.map { |rec| [rec[select_label_name], rec[select_value_name]] }
  # end
  #
  # def select_label_name
  #   @sel_label_name ||= select_options[:label] || select_options[:value]
  # end
  #
  # def select_value_name
  #   @sel_value_name ||= select_options[:value]
  # end
  #
  # def make_order(dataset)
  #   if select_options[:desc]
  #     dataset.order_by(Sequel.desc(select_options[:order_by]))
  #   else
  #     dataset.order_by(select_options[:order_by])
  #   end
  # end

end