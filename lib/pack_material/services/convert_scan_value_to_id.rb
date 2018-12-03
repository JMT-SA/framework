# frozen_string_literal: true

module PackMaterialApp
  # Take scanned values for location or SKU and return id values.
  # Example
  #    ConvertScanValueToId.call(location: 'ABC', sku: [123, 456])
  #    # => { location: [1], sku: [1,2] }
  #
  class ConvertScanValueToId < BaseService
    def initialize(options = {})
      raise ArgumentError if options.empty?
      raise ArgumentError, 'Options keys must be one of :location or :sku' unless options.keys.all? { |key| %i[location sku].include?(key) }
      @options = options
      @id_values = Hash[options.keys.map { |a| [a, []] }]
    end

    def call
      @options.each do |key, values|
        case key
        when :location
          build_location_ids(Array(values))
        when :sku
          build_sku_ids(Array(values))
        end
      end
      success_response('ok', @id_values)
    rescue Crossbeams::FrameworkError => e
      failed_response(e.message)
    end

    private

    def build_location_ids(values)
      # values can be ids, location codes OR 3-alpha legacy barcodes.
      values.each do |value|
        @id_values[:location] << case value
                                 when /\A\w\w\w\Z/ # 3-character alpha: A legacy barcode
                                   location_legacy_barcode(value)
                                 when /\w/         # Contains alpha characters: A location code
                                   location_location_code(value)
                                 else
                                   repo = ReplenishRepo.new
                                   raise Crossbeams::FrameworkError, "Location id \"#{value}\" does not exist" unless repo.exists?(:locations, id: value)
                                   value.to_i
                                 end
      end
    end

    def location_legacy_barcode(value)
      repo = ReplenishRepo.new
      id = repo.location_id_from_legacy_barcode(value)
      raise Crossbeams::FrameworkError, "Legacy barcode \"#{value}\" does not exist" if id.nil?
      id
    end

    def location_location_code(value)
      repo = ReplenishRepo.new
      id = repo.location_id_from_location_code(value)
      raise Crossbeams::FrameworkError, "Location code \"#{value}\" does not exist" if id.nil?
      id
    end

    def build_sku_ids(values)
      # values are always sku_numbers.
      repo = ReplenishRepo.new
      ids = repo.sku_ids_from_numbers(values)
      raise Crossbeams::FrameworkError, "One or more of SKU numbers: \"#{values.join(', ')}\" do not exist" if ids.length != values.length
      @id_values[:sku] = ids
    end
  end
end
