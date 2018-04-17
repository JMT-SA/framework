# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize

module MasterfilesApp
  class TestCommodityRepo < MiniTestWithHooks

    def test_for_selects
      assert_respond_to repo, :for_select_commodity_groups
      assert_respond_to repo, :for_select_commodities
    end

    def test_crud_calls
      assert_respond_to repo, :find_commodity_group
      assert_respond_to repo, :create_commodity_group
      assert_respond_to repo, :update_commodity_group
      assert_respond_to repo, :delete_commodity_group

      assert_respond_to repo, :find_commodity
      assert_respond_to repo, :create_commodity
      assert_respond_to repo, :update_commodity
      assert_respond_to repo, :delete_commodity
    end

    private

    def repo
      CommodityRepo.new
    end
  end
end
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/AbcSize
