# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize

module MasterfilesApp
  class TestTargetMarketRepo < MiniTestWithHooks

    def test_for_selects
      assert_respond_to repo, :for_select_tm_group_types
      assert_respond_to repo, :for_select_tm_groups
      assert_respond_to repo, :for_select_target_markets
    end

    def test_crud_calls
      assert_respond_to repo, :find_tm_group_type
      assert_respond_to repo, :create_tm_group_type
      assert_respond_to repo, :update_tm_group_type
      assert_respond_to repo, :delete_tm_group_type

      assert_respond_to repo, :find_tm_group
      assert_respond_to repo, :create_tm_group
      assert_respond_to repo, :update_tm_group
      assert_respond_to repo, :delete_tm_group

      assert_respond_to repo, :find_target_market
      assert_respond_to repo, :create_target_market
      assert_respond_to repo, :update_target_market
      assert_respond_to repo, :delete_target_market
    end

    private

    def repo
      TargetMarketRepo.new
    end
  end
end
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/AbcSize
