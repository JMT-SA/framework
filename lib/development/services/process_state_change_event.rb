# frozen_string_literal: true

module DevelopmentApp
  # Service to call relevent service on an event change.
  class ProcessStateChangeEvent < BaseService
    def initialize(id, table_name, event_type, user_name, options)
      @id = id
      @table_name = table_name
      @event_type = event_type
      @user_name = user_name
      @options = options
    end

    def call
      case @event_type
      when :completed
        ProcessCompleteEvent.call(@id, @table_name, @user_name, @options)
      end
    end
  end
end
