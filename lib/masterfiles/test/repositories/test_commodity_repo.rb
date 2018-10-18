# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MasterfilesApp
  class TestCommodityRepo < MiniTestWithHooks
    def test_for_selects
      assert_respond_to repo, :for_select_commodity_groups
      assert_respond_to repo, :for_select_commodities
    end

    def test_crud_calls
      test_crud_calls_for :commodity_groups, name: :commodity_group, wrapper: CommodityGroup
      test_crud_calls_for :commodities, name: :commodity, wrapper: Commodity
    end

    private

    def repo
      CommodityRepo.new
    end
  end
end
