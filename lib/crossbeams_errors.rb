# frozen_string_literal: true

module Crossbeams
  # When something in the framework goes wrong/is not called properly.
  class FrameworkError < StandardError
  end

  # When an exception has occurred and you want just the message to be conveyed to the user.
  class InfoError < StandardError
  end

  # User does not have the required permission.
  class AuthorizationError < StandardError
  end

  # The task is not permitted.
  class TaskNotPermittedError < StandardError
  end
end
