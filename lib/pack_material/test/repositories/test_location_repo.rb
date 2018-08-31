# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize

module PackMaterialApp
  class TestLocationRepo < MiniTestWithHooks

    def test_for_selects
      assert_respond_to repo, :for_select_locations
    end

    def test_crud_calls
      assert_respond_to repo, :find_location
      assert_respond_to repo, :create_location
      assert_respond_to repo, :update_location
      assert_respond_to repo, :delete_location
    end

    private

    def repo
      LocationRepo.new
    end
  end
end
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/AbcSize
