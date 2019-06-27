# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module PackMaterialApp
  class TestMrBulkStockAdjustmentItemInteractor < Minitest::Test
    def test_repo
      repo = interactor.repo
      # repo = interactor.send(:repo)
      assert repo.is_a?(PackMaterialApp::TransactionsRepo)
    end

    private

    def interactor
      @interactor ||= MrBulkStockAdjustmentItemInteractor.new(current_user, {}, {}, {})
    end
  end
end
