# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MasterfilesApp
  class TestFruitSizeInteractor < Minitest::Test
    def test_repo
      fruit_size_repo = interactor.send(:repo)
      assert fruit_size_repo.is_a?(MasterfilesApp::FruitSizeRepo)
    end

    private

    def interactor
      @interactor ||= FruitSizeInteractor.new(current_user, {}, {}, {})
    end
  end
end
