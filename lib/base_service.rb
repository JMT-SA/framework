class BaseService
  include Crossbeams::Responses

  class << self
    def call(*args)
      new(*args).call
    end
  end
end
