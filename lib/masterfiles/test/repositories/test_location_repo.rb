# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize

module MasterfilesApp
  class TestLocationRepo < MiniTestWithHooks
    def test_for_selects
      assert_respond_to repo, :for_select_locations
      assert_respond_to repo, :for_select_location_assignments
      assert_respond_to repo, :for_select_location_storage_types
      assert_respond_to repo, :for_select_location_types
    end

    def test_crud_calls
      test_crud_calls_for :locations, name: :location
      test_crud_calls_for :location_assignments, name: :location_assignment, wrapper: LocationAssignment
      test_crud_calls_for :location_storage_types, name: :location_storage_type, wrapper: LocationStorageType
      test_crud_calls_for :location_types, name: :location_type, wrapper: LocationType
    end

    def test_location_code_suggestion
      skip 'factories needed'
      # tree_locations
      # ancestor, descendent, path length
      # 1	1	0
      # 1	2	1
      # 2	2	0
      # 1	3	2
      # 2	3	1
      # 3	3	0
      # 1	4	1
      # 4	4	0

      # id, storage_type id, location type id, assignment id, location code
      # 1	2	4	9	One
      # 2	2	5	9	Two
      # 3	8	4	9	Three
      # 4	8	4	9	Four

      # (ancestor_id, location_type_id)
      # sibling_count = DB[:tree_locations].where(path_length: 1).where(ancestor_location_id: ancestor_id).count
      # code = ''
      # code += "#{find_hash(:locations, ancestor_id)[:location_code]}_" unless location_is_root?(ancestor_id)
      # code += type_abbreviation(location_type_id) + (sibling_count + 1).to_s
      # success_response('ok', code)
    end

    def test_type_abbreviation
      type_id = DB[:location_types].insert(
        location_type_code: 'location type',
        short_code: 'LT'
      )
      x = repo.type_abbreviation(type_id)
      assert_equal 'LT', x
    end

    def test_location_is_root?
      skip 'factories needed'
      # (id)
      # DB[:tree_locations].where(descendant_location_id: id).count == 1
    end

    private

    def repo
      LocationRepo.new
    end
  end
end
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/AbcSize
