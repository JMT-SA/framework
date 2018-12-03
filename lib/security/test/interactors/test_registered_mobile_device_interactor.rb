# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize

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
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/AbcSize
