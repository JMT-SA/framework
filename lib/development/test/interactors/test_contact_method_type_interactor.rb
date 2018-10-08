# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module DevelopmentApp
  class TestContactMethodTypeInteractor < Minitest::Test
    def test_repo
      repo = interactor.repo
      # repo = interactor.send(:repo)
      assert repo.is_a?(DevelopmentApp::ContactMethodTypeRepo)
    end

    private

    def interactor
      @interactor ||= ContactMethodTypeInteractor.new(current_user, {}, {}, {})
    end
  end
end
