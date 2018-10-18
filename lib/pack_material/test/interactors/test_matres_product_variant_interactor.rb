# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module PackMaterialApp
  class TestMatresProductVariantInteractor < Minitest::Test
    def test_repo
      repo = interactor.send(:repo)
      assert repo.is_a?(PackMaterialApp::ConfigRepo)
    end

    private

    def interactor
      @interactor ||= MatresProductVariantInteractor.new(current_user, {}, {}, {})
    end
  end
end
