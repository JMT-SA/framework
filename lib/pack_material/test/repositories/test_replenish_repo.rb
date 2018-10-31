# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize

module PackMaterialApp
  class TestReplenishRepo < MiniTestWithHooks

    def test_for_selects
      assert_respond_to repo, :for_select_mr_purchase_orders
    end

    def test_crud_calls
      test_crud_calls_for :mr_purchase_orders, name: :mr_purchase_order, wrapper: MrPurchaseOrder
    end

    private

    def repo
      ReplenishRepo.new
    end
  end
end
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/AbcSize
