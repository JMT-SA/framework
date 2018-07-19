# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize

module PackMaterialApp
  class TestPmProductRepo < MiniTestWithHooks

    def test_for_selects
      assert_respond_to repo, :for_select_pm_product
      assert_respond_to repo, :for_select_pm_product_variant
    end

    def test_crud_calls
      assert_respond_to repo, :find_pm_product
      assert_respond_to repo, :create_pm_product
      assert_respond_to repo, :update_pm_product
      assert_respond_to repo, :delete_pm_product

      assert_respond_to repo, :find_pm_product_variant
      assert_respond_to repo, :create_pm_product_variant
      assert_respond_to repo, :update_pm_product_variant
      assert_respond_to repo, :delete_pm_product_variant
    end

    private

    def repo
      PmProductRepo.new
    end
  end
end
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/AbcSize
