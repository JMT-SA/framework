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

  # Add a created_by key to a changeset and set its value to the current user.
  #
  # @param changeset [Hash, DryStruct] the changeset.
  # @return [Hash] the augmented changeset.
  def include_created_by_in_changeset(changeset)
    changeset.to_h.merge(created_by: @user.user_name)
  end

  # Add an updated_by key to a changeset and set its value to the current user.
  #
  # @param changeset [Hash, DryStruct] the changeset.
  # @return [Hash] the augmented changeset.
  def include_updated_by_in_changeset(changeset)
    changeset.to_h.merge(updated_by: @user.user_name)
  end

  # Mark an entity as complete.
  #
  # @param table_name [string] the table.
  # @param id [integer] the record id.
  # @param enqueue_job [true, false] should an alert job be enqueued? Default true.
  # @return [SuccessResponse]
  def complete_a_record(table_name, id, opts)
    update_table_with_status(table_name,
                             id,
                             :completed,
                             field_changes: { completed: true },
                             params: opts)
  end

  # Mark an entity as rejected.
  #
  # @param (see #complete_a_record)
  # @return (see #complete_a_record)
  def reject_a_record(table_name, id, opts)
    update_table_with_status(table_name,
                             id,
                             :rejected,
                             field_changes: { completed: false },
                             params: opts)
  end

  # Mark an entity as approved.
  #
  # @param (see #complete_a_record)
  # @return (see #complete_a_record)
  def approve_a_record(table_name, id, opts)
    update_table_with_status(table_name,
                             id,
                             :approved,
                             field_changes: { approved: true },
                             params: opts)
  end

  # Mark an entity as reopened.
  #
  # @param (see #complete_a_record)
  # @return (see #complete_a_record)
  def reopen_a_record(table_name, id, opts)
    update_table_with_status(table_name,
                             id,
                             :reopened,
                             field_changes: { approved: false, completed: false },
                             params: opts)
  end

  # Update the status of a record and log the status change and transaction.
  #
  # @param table_name [symbol] the name of the table
  # @param id [integer] the record id.
  # @param status_change [symbol] the type of status change.
  # @param opts [Hash] the options.
  # @option opts [Hash] :field_changes The fields and their values to be updated.
  # @option opts [String] :status_text The optional text to record as the status. If not provided, the value of <tt>status_change</tt> will be capitalized and used.
  # @option opts [Boolean] :enqueue_job Should an alert job for this status change be enqueued?
  # @return [SuccessResponse]
  def update_table_with_status(table_name, id, status_change, opts = {}) # rubocop:disable Metrics/AbcSize
    # ValidateStateChangeService.call(table_name, id, status_change, @user)
    repo.transaction do
      repo.update(table_name, id, opts[:field_changes])
      log_status(table_name, id, opts[:status_text] || status_change.to_s.upcase)
      log_transaction
      DevelopmentApp::ProcessStateChangeEvent.call(id, table_name, status_change, @user.user_name, opts[:params])
    end
    success_response((opts[:status_text] || status_change.to_s).capitalize)
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
