# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize

module MasterfilesApp
  class TestCultivarRepo < MiniTestWithHooks
    def test_for_selects
      assert_respond_to repo, :for_select_cultivar_groups
      assert_respond_to repo, :for_select_cultivars
      assert_respond_to repo, :for_select_marketing_varieties
    end

    def test_crud_calls
      assert_respond_to repo, :find_cultivar_group
      assert_respond_to repo, :create_cultivar_group
      assert_respond_to repo, :update_cultivar_group
      assert_respond_to repo, :delete_cultivar_group

      assert_respond_to repo, :find_cultivar
      assert_respond_to repo, :create_cultivar
      assert_respond_to repo, :update_cultivar
      assert_respond_to repo, :delete_cultivar

      assert_respond_to repo, :find_marketing_variety
      assert_respond_to repo, :create_marketing_variety
      assert_respond_to repo, :update_marketing_variety
      assert_respond_to repo, :delete_marketing_variety
    end

    private

    def repo
      CultivarRepo.new
    end
  end
end
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/AbcSize
