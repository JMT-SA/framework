# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module DevelopmentApp
  class TestStatusRepo < MiniTestWithHooks
    def test_find_with_logs
      skip
    end

    private

    def repo
      StatusRepo.new
    end
  end
end
