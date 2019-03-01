require 'observer'

class BaseService
  include Crossbeams::Responses
  include Observable

  class << self
    def call(*args)
      new(*args).call
    end
  end

  def load_observers
    Array(declared_observers).each do |observer|
      klass = Module.const_get(observer)
      add_observer(klass.new)
    end
  end

  def declared_observers
    Crossbeams::Config::ObserversList::OBSERVERS_LIST[self.class.to_s]
  end

  # Helper to return a basic SuccessResponse.
  #
  # @return [SuccessResponse]
  def all_ok
    success_response 'Permission ok'
  end
end
