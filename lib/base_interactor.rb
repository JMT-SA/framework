# frozen_string_literal: true

class BaseInteractor
  include Crossbeams::Responses

  def initialize(user, client_settings, context, logger)
    @user = user
    @client_settings = client_settings
    @context = OpenStruct.new(context)
    @logger = logger
  end

  # Check if a record exists in the database.
  #
  # @param entity [Symbol] the table name.
  # @param id [Integer] the id to check.
  def exists?(entity, id)
    repo = RepoBase.new
    repo.exists?(entity, id: id)
  end

  # Log the context of a transaction. Uses the context passed to the Interactor constructor.
  def log_transaction
    repo.log_action(user_name: @user.user_name, context: @context.context, route_url: @context.route_url)
  end
end
