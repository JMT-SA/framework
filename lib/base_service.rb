# frozen_string_literal: true

require 'observer'

class BaseService
  include Crossbeams::Responses
  include Observable
  include Crossbeams::MessageBus

  class << self
    def call(*args, &block)
      if block_given?
        new(*args, block).call
      else
        new(*args).call
      end
    end
  end

  # Load any observers declared for this service.
  def load_observers
    Array(declared_observers).each do |observer|
      klass = Module.const_get(observer)
      add_observer(klass.new)
    end
  end

  # List of observerd declared for this service.
  def declared_observers
    Crossbeams::Config::ObserversList::OBSERVERS_LIST[self.class.to_s]
  end

  # Helper to return a basic SuccessResponse.
  # Use this when no data is required to be returned from the call.
  #
  # @return [SuccessResponse]
  def all_ok
    success_response 'Permission ok'
  end
end
