# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MasterfilesApp
  class TestCommodityInteractor < Minitest::Test
    def test_repo
      repo = interactor.send(:repo)
      assert repo.is_a?(MasterfilesApp::CommodityRepo)
    end

    private

    def interactor
      @interactor ||= CommodityInteractor.new(current_user, {}, {}, {})
    end
  end
end
