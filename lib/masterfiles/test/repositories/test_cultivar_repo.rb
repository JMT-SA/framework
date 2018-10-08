# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MasterfilesApp
  class TestCultivarRepo < MiniTestWithHooks
    def test_for_selects
      assert_respond_to repo, :for_select_cultivar_groups
      assert_respond_to repo, :for_select_cultivars
      assert_respond_to repo, :for_select_marketing_varieties
    end

    def test_crud_calls
      test_crud_calls_for :cultivar_groups, name: :cultivar_group, wrapper: CultivarGroup
      test_crud_calls_for :cultivars, name: :cultivar, wrapper: Cultivar
      test_crud_calls_for :marketing_varieties, name: :marketing_variety, wrapper: MarketingVariety
    end

    private

    def repo
      CultivarRepo.new
    end
  end
end
