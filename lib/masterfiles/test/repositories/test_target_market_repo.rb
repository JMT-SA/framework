# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MasterfilesApp
  class TestTargetMarketRepo < MiniTestWithHooks
    def test_for_selects
      assert_respond_to repo, :for_select_tm_group_types
      assert_respond_to repo, :for_select_tm_groups
      assert_respond_to repo, :for_select_target_markets
    end

    def test_crud_calls
      test_crud_calls_for :target_market_group_types, name: :tm_group_type, wrapper: TmGroupType
      test_crud_calls_for :target_market_groups, name: :tm_group, wrapper: TmGroup
      test_crud_calls_for :target_markets, name: :target_market, wrapper: TargetMarket
    end

    private

    def repo
      TargetMarketRepo.new
    end
  end
end
