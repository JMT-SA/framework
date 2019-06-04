# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module DevelopmentApp
  class TestUserEmailGroupInteractor < Minitest::Test
    def test_repo
      repo = interactor.repo
      # repo = interactor.send(:repo)
      assert repo.is_a?(DevelopmentApp::UserRepo)
    end

    private

    def interactor
      @interactor ||= UserEmailGroupInteractor.new(current_user, {}, {}, {})
    end
  end
end
