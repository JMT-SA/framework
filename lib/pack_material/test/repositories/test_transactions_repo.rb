# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module PackMaterialApp
  class TestTransactionsRepo < MiniTestWithHooks
    def test_for_selects
      assert_respond_to repo, :for_select_mr_inventory_transactions
    end

    def test_crud_calls
      test_crud_calls_for :mr_inventory_transactions, name: :mr_inventory_transaction, wrapper: MrInventoryTransaction
    end

    private

    def repo
      TransactionsRepo.new
    end
  end
end
