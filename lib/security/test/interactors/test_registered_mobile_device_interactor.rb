# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module SecurityApp
  class TestRegisteredMobileDeviceInteractor < Minitest::Test
    def test_repo
      repo = interactor.repo
      # repo = interactor.send(:repo)
      assert repo.is_a?(SecurityApp::RegisteredMobileDeviceRepo)
    end

    private

    def interactor
      @interactor ||= RegisteredMobileDeviceInteractor.new(current_user, {}, {}, {})
    end
  end
end
