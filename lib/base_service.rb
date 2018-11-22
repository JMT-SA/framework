class BaseService
  include Crossbeams::Responses

  class << self
    def call(*args)
      new(*args).call
    end
  end

  def all_ok
    success_response 'Permission ok'
  end
end
