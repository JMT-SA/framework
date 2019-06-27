# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module PackMaterialApp
  class TestMrPurchaseOrderInteractor < Minitest::Test
    def test_repo
      repo = interactor.send(:repo)
      assert repo.is_a?(PackMaterialApp::ReplenishRepo)
    end

    private

    def interactor
      @interactor ||= MrPurchaseOrderInteractor.new(current_user, {}, {}, {})
    end
  end
end
