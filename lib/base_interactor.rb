# frozen_string_literal: true

class BaseInteractor
  include Crossbeams::Responses

  def initialize(user, client_settings, context, logger)
    @user = user
    @client_settings = client_settings
    @context = context
    @logger = logger
  end

  def exists?(entity, id)
    repo = RepoBase.new
    repo.exists?(entity, id: id)
  end
end
