# frozen_string_literal: true

class BaseInteractor # rubocop:disable Metrics/ClassLength
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
    repo.log_action(user_name: @user.user_name, context: @context.context, route_url: @context.route_url, request_ip: @context.request_ip)
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

  # Add context to a message for emailing.
  # (adds the route and ip address)
  #
  # @param message [string] the message to appear in the body of the message
  # @return [string] the message decorated with path and ip data.
  def decorate_mail_message(message)
    "#{message}\n\nRoute: #{@context.route_url}\n\nIP: #{@context.request_ip}"
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

  # Remove all parameters for an +extended_columns+ field from a normal params object.
  # Return the params and the extended_columns separately.
  #
  # @param params [Hash] the request parameters.
  # @return [Array] the params and extended_columns Hashes.
  def unwrap_extended_columns_params(params)
    parms = {}
    ext = {}
    params.each do |name, value|
      if name.to_s.start_with?('extcol_')
        ext[name.to_s.delete_prefix('extcol_').to_sym] = value
      else
        parms[name] = value
      end
    end
    [parms, ext]
  end

  # Return all parameters for an +extended_columns+ field from a params object.
  # The keys of the resulting hash can optionally retain the "extcol_" prefix or have it stripped off.
  #
  # @param params [Hash] the request parameters.
  # @param delete_prefix [boolean] should the "extcol_" prefix be removed from the keys? Default true.
  # @return [Hash] the extended_columns Hash.
  def select_extended_columns_params(params, delete_prefix: true)
    selection = params.select { |a| a.to_s.start_with?('extcol_') }
    if delete_prefix
      selection.transform_keys { |k| k.to_s.delete_prefix('extcol_').to_sym }
    else
      selection
    end
  end

  # Apply validation rules to a set of extended_columns and return the results.
  #
  # @param table [Symbol] the table name.
  # @param params [Hash] the request parameters.
  # @return [OpenStruct] validation results.
  def validate_extended_columns(table, params)
    validator = Crossbeams::Config::ExtendedColumnDefinitions.validation_for(table)
    return OpenStruct.new(messages: {}) unless validator

    res = validator.call(select_extended_columns_params(params))
    errs = { messages: res.errors.to_h.transform_keys { |k| "extcol_#{k}".to_sym } }
    fields = res.to_h.transform_keys { |k| "extcol_#{k}".to_sym }
    OpenStruct.new(errs.merge(fields))
  end

  # Add extended_columns to a changeset.
  #
  # @param changeset [Hash, DryStruct] the changeset.
  # @param repo [BaseRepository] any repository.
  # @param extended_cols [Hash] the extended_column values.
  # @return [Hash] the augmented changeset.
  def add_extended_columns_to_changeset(changeset, repo, extended_cols)
    changeset.to_h.merge(extended_columns: repo.hash_for_jsonb_col(extended_cols))
  end

  # Get the extended_columns hash from an instance and change the keys from strings to symbols.
  #
  # @param instance [DryStruct/Hash] the data instance.
  # @return [Hash] the extended_columns Hash or an empty Hash.
  def extended_columns_for_row(instance)
    return {} unless instance.to_h[:extended_columns]

    instance.to_h[:extended_columns].transform_keys(&:to_sym)
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
  # @param status_change [string] the type of status change.
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
    success_response((opts[:status_text] || status_change.to_s).gsub('_', ' ').capitalize)
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

  # When expecting an id value from a `changed_value` parameter,
  # validate for blank/integer.
  #
  # @param params [Hash] the request parameters.
  # @return [DryValidationResponse]
  def validate_changed_value_as_int(params)
    Dry::Schema.Params do
      required(:changed_value).maybe(:integer)
    end.call(params)
  end

  # When expecting a string value from a `changed_value` parameter,
  # validate for blank/string.
  #
  # @param params [Hash] the request parameters.
  # @return [DryValidationResponse]
  def validate_changed_value_as_str(params)
    Dry::Schema.Params do
      required(:changed_value).maybe(:str?)
    end.call(params)
  end

  # Using an ip address, return a robot HTTP base_url (host + port).
  #
  # @param ip [string] the ip address of the robot.
  # @return [string] the HTTP host address and port for the robot.
  def robot_print_base_ulr(ip)
    "http://#{ip}:2080/"
  end
end
