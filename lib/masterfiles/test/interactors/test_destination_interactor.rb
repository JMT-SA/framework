# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize

module MasterfilesApp
  class TestDestinationInteractor < Minitest::Test
    def test_repo
      destination_repo = interactor.send(:destination_repo)
      assert destination_repo.is_a?(MasterfilesApp::DestinationRepo)
    end

    private

    def interactor
      @interactor ||= DestinationInteractor.new(current_user, {}, {}, {})
    end
  end
end
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/AbcSize
