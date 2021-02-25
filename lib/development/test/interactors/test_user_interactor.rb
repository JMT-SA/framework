# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module DevelopmentApp
  class TestUserInteractor < Minitest::Test
    def test_repo
      repo = interactor.send(:repo)
      assert repo.is_a?(DevelopmentApp::UserRepo)
    end

    def test_update
      ok = { user_name: 'ANAME', email: 'email@place.com' }
      res = interactor.send(:validate_user_params, ok)
      assert_empty res.errors

      not_ok = [
        [{ email: 'email@place.com' }, { user_name: ['is missing'] }],
        [{ user_name: 'ANAME' }, { email: ['is missing'] }]
      ]
      not_ok.each do |params, expect|
        res = interactor.send(:validate_user_params, params)
        assert_equal expect, res.errors.to_h
      end
    end

    private

    def interactor
      @interactor ||= UserInteractor.new(current_user, {}, {}, {})
    end
  end
end
