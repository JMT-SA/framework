# frozen_string_literal: true

class BaseInteractor
  include Crossbeams::Responses

  # Create an Interactor.
  #
  # @param user [User] current user.
  # @param client_settings [Hash]
  # @param context [Hash]
  # @param logger [Hash]
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
  # @return [Boolean]
  def exists?(entity, id)
    repo = BaseRepo.new
    repo.exists?(entity, id: id)
  end

  # Log the context of a transaction. Uses the context passed to the Interactor constructor.
  #
  # @return [void]
  def log_transaction
    repo.log_action(user_name: @user.user_name, context: @context.context, route_url: @context.route_url)
  end

  # Log the status of a record. Uses the context passed to the Interactor constructor.
  #
  # The status is written to `audit.current_statuses` and appended to `audit.status_logs`.
  #
  # @param table_name [Symbol] the table.
  # @param id [Integer] the id of the record.
  # @param status [String] the status to be associated with the record.
  # @param comment [nil, String] an optional comment that further describes the state change.
  # @return [void]
  def log_status(table_name, id, status, comment: nil)
    repo.log_status(table_name, id, status, user_name: @user.user_name, comment: comment)
  end

  # Log the status of multiple records. Uses the context passed to the Interactor constructor.
  #
  # The statuses are written to `audit.current_statuses` and appended to `audit.status_logs`.
  #
  # @param table_name [Symbol] the table.
  # @param ids [Array, Integer] the ids of the records.
  # @param status [String] the status to be associated with the record.
  # @param comment [nil, String] an optional comment that further describes the state change.
  # @return [void]
  def log_multiple_statuses(table_name, ids, status, comment: nil)
    repo.log_multiple_statuses(table_name, ids, status, user_name: @user.user_name, comment: comment)
  end
end
