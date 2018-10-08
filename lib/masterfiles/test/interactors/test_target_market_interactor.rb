# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MasterfilesApp
  class TestTargetMarketInteractor < Minitest::Test
    def test_repo
      repo = interactor.send(:repo)
      assert repo.is_a?(MasterfilesApp::TargetMarketRepo)
    end

    private

    def interactor
      @interactor ||= TargetMarketInteractor.new(current_user, {}, {}, {})
    end
  end
end
