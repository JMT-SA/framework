# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module DevelopmentApp
  class TestAddressTypeInteractor < Minitest::Test
    def test_repo
      repo = interactor.repo
      # repo = interactor.send(:repo)
      assert repo.is_a?(DevelopmentApp::AddressTypeRepo)
    end

    private

    def interactor
      @interactor ||= AddressTypeInteractor.new(current_user, {}, {}, {})
    end
  end
end
