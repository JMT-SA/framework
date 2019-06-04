# frozen_string_literal: true

require 'csv'

module MasterfilesApp
  class ImportLocations < BaseService # rubocop:disable Metrics/ClassLength
    attr_reader :filename, :csv_data, :errs, :repo

    VALID_HEADERS = %w[
      parent_location
      location_long_code
      location_short_code
      print_code
      location_description
      primary_storage_type
      location_type
      primary_assignment
      storage_definition
      assignments
      storage_types
      has_single_container
      virtual_location
      consumption_area
      can_be_moved
      can_store_stock
    ].freeze

    def initialize(filename)
      @filename = Pathname.new(filename)
      @repo = LocationRepo.new
      @errs = []
    end

    def call
      res = validate_file
      return res unless res.success

      res = validate_data
      return res unless res.success

      # import rows in transaction
      repo.transaction do
        import_locations
      end

      success_response('Locations added')
    end

    private

    def import_locations # rubocop:disable Metrics/AbcSize
      lkp_types = Hash[repo.for_select_location_types]
      lkp_storage = Hash[repo.for_select_location_storage_types]
      lkp_assign = Hash[repo.for_select_location_assignments]
      lkp_stg_def = Hash[repo.for_select_location_storage_definitions]
      lookups = {}
      csv_data.each do |row| # rubocop:disable Metrics/BlockLength
        short_code = row['location_short_code'] || next_short_code(row['primary_storage_type'])
        if row['parent_location'].nil?
          lookups[row['location_long_code']] = repo.create_root_location(
            location_long_code: row['location_long_code'],
            location_short_code: short_code,
            location_description: row['location_description'] || row['location_long_code'],
            print_code: row['print_code'],
            location_type_id: lkp_types[row['location_type']],
            primary_storage_type_id: lkp_storage[row['primary_storage_type']],
            primary_assignment_id: lkp_assign[row['primary_assignment']],
            location_storage_definition_id: lkp_stg_def[row['storage_definition']],
            has_single_container: row['has_single_container'] == 't',
            virtual_location: row['virtual_location'] == 't',
            consumption_area: row['consumption_area'] == 't',
            can_be_moved: row['can_be_moved'] == 't',
            can_store_stock: row['can_store_stock'] == 't'
          )
        else
          parent_id = lookups[row['parent_location']] || repo.location_id_from_long_code(row['parent_location'])
          lookups[row['location_long_code']] = repo.create_child_location(
            parent_id,
            location_long_code: row['location_long_code'],
            location_short_code: short_code,
            location_description: row['location_description'] || row['location_long_code'],
            print_code: row['print_code'],
            location_type_id: lkp_types[row['location_type']],
            primary_storage_type_id: lkp_storage[row['primary_storage_type']],
            primary_assignment_id: lkp_assign[row['primary_assignment']],
            location_storage_definition_id: lkp_stg_def[row['storage_definition']],
            has_single_container: row['has_single_container'] == 't',
            virtual_location: row['virtual_location'] == 't',
            consumption_area: row['consumption_area'] == 't',
            can_be_moved: row['can_be_moved'] == 't',
            can_store_stock: row['can_store_stock'] == 't'
          )
        end
        # Add any extra stg/asign
      end
    end

    def next_short_code(storage_code)
      res = repo.suggested_short_code(storage_code, id_lookup: false)
      raise Crossbeams::InfoError, res.message unless res.success

      res.instance
    end

    def check_primary_storage_types
      stg_types = csv_data.map { |r| r['primary_storage_type'] }.uniq
      errs << 'Cannot have a blank primary storage type' if stg_types.any?(&:nil?)
      res = repo.check_location_storage_types(stg_types)
      errs << res.message unless res.success
    end

    def check_location_types
      loc_types = csv_data.map { |r| r['location_type'] }.uniq
      errs << 'Cannot have a blank location type' if loc_types.any?(&:nil?)
      res = repo.check_location_types(loc_types.compact)
      errs << res.message unless res.success
    end

    def check_primary_assignments
      asn_types = csv_data.map { |r| r['primary_assignment'] }.uniq
      errs << 'Cannot have a blank primary assignment' if asn_types.any?(&:nil?)
      res = repo.check_location_assignments(asn_types.compact)
      errs << res.message unless res.success
    end

    def check_storage_definitions
      stg_defs = csv_data.map { |r| r['storage_definition'] }.uniq
      return if stg_defs.compact.empty?

      res = repo.check_storage_definitions(stg_defs.compact)
      errs << res.message unless res.success
    end

    def check_assignments # rubocop:disable Metrics/AbcSize
      asns = csv_data.map { |r| r['assignments'].nil? ? [nil] : r['assignments'].split(',') }.flatten.uniq
      errs << 'Cannot have blank assignments' if asns.any?(&:nil?)
      res = repo.check_location_assignments(asns.compact)
      errs << res.message unless res.success
    end

    def check_storage_types # rubocop:disable Metrics/AbcSize
      stgs = csv_data.map { |r| r['storage_types'].nil? ? [nil] : r['storage_types'].split(',') }.flatten.uniq
      errs << 'Cannot have blank storage types' if stgs.any?(&:nil?)
      res = repo.check_location_storage_types(stgs.compact)
      errs << res.message unless res.success
    end

    def check_each_row # rubocop:disable Metrics/AbcSize
      csv_data.each do |row|
        errs << "primary storage type not in storage types for #{row['location_long_code']}" unless (row['storage_types'] || '').split(';').include?(row['primary_storage_type'])
        errs << "primary assignment not in assignments for #{row['location_long_code']}" unless (row['assignments'] || '').split(';').include?(row['primary_assignment'])
        res = repo.location_exists(row['location_long_code'], row['location_short_code'])
        errs << res.message unless res.success
      end
    end

    def validate_data # rubocop:disable Metrics/AbcSize
      check_primary_storage_types
      check_location_types
      check_primary_assignments
      check_storage_definitions
      check_assignments
      check_storage_types
      check_location_errors

      return failed_response(errs.join(', ')) unless errs.empty?

      check_each_row
      if errs.empty?
        ok_response
      else
        failed_response(errs.join(', '))
      end
    end

    def parents
      @parents ||= csv_data.map { |r| r['parent_location'] }.compact.uniq
    end

    def locations
      @locations ||= csv_data.map { |r| r['location_long_code'] }
    end

    def check_location_errors # rubocop:disable Metrics/AbcSize
      errs << 'Location long codes are not unique' if locations.length != locations.uniq.length
      should_exist = parents - locations
      return if should_exist.empty?

      res = repo.check_locations(should_exist.compact)
      errs << res.message unless res.success
      # errs << 'Not all parent location are valid locations' unless (parents - locations).empty? # This should check db for existing locs too...
    end

    def read_csv
      @csv_data = CSV.read(filename, headers: true)
    end

    def validate_file
      return failed_response(%(File "#{filename}" does not exist)) unless file_exists?
      return failed_response(%(File "#{filename}" does not have .csv extension)) unless ext_is_ok?

      read_csv
      return failed_response('CSV does not have the exact required set of headers') unless headers_equivalent?

      ok_response
    end

    def file_exists?
      filename.exist?
    end

    def ext_is_ok?
      filename.extname.casecmp('.csv').zero?
    end

    def headers_equivalent?
      head1 = VALID_HEADERS
      head2 = csv_data.headers

      head1 | head2 == head1 && head1.length == head2.length
    end
  end
end
__END__
parent_location,location_long_code,location_short_code,print_code,location_description,primary storage type,location_type,primary_assignment,assignments,storage_types,has_single_container,virtual_location,consumption_area,can_be_moved
,AAA,AAA,AAA,AAA,Pack Material,SITE,SITE,SITE,Pack Material,,,,
AAA,BBB,BBB,BBB,BBB,Pack Material,BUILDING,STORAGE,STORAGE,,,,,
BBB,CCC,CCC,CCC,CCC,Pack Material,ROOM,STORAGE,STORAGE,Pack Material,,,,
