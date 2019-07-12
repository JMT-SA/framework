# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MasterfilesApp
  class TestContactMethodInteractor < Minitest::Test
    def test_party_repo
      party_repo = interactor.send(:repo)
      assert party_repo.is_a?(MasterfilesApp::PartyRepo)
    end

    private

    def interactor
      @interactor ||= ContactMethodInteractor.new(current_user, {}, {}, {})
    end
  end
end
