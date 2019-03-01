# frozen_string_literal: true

module Crossbeams
  module Config
    class ObserversList
      OBSERVERS_LIST = {
        # 'DevelopmentApp::GenerateNewScaffold' => ['DevelopmentApp::TestObserver']
      }.freeze
    end
  end
end
# NOTE: to make this configurable per implementation, we could feed a default observers list through a script unique to
#       the installation, that removes or changes observers in the arrays and returns a new, specific Hash to OBSERVERS_LIST.
