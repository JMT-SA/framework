# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize

module MasterfilesApp
  class TestFruitActualCountsForPackInteractor < Minitest::Test
    def test_repo
      fruit_size_repo = interactor.send(:fruit_size_repo)
      assert fruit_size_repo.is_a?(MasterfilesApp::FruitSizeRepo)
    end

    private

    def interactor
      @interactor ||= FruitActualCountsForPackInteractor.new(current_user, {}, {}, {})
    end
  end
end
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/AbcSize
