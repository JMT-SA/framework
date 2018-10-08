# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MasterfilesApp
  class TestCultivarInteractor < Minitest::Test
    def test_repo
      cultivar_repo = interactor.send(:cultivar_repo)
      assert cultivar_repo.is_a?(MasterfilesApp::CultivarRepo)
    end

    private

    def interactor
      @interactor ||= CultivarInteractor.new(current_user, {}, {}, {})
    end
  end
end
