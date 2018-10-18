# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module DevelopmentApp
  class TestLoggingInteractor < Minitest::Test
    def test_repo
      repo = interactor.repo
      assert repo.is_a?(DevelopmentApp::LoggingRepo)
    end

    def test_exists
      skip 'todo: test that non-base exists method works'
    end

    private

    def interactor
      @interactor ||= LoggingInteractor.new(current_user, {}, {}, {})
    end
  end
end
