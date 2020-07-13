# frozen_string_literal: true

# Base class for running scripts that have access to the config, database and job queue.
#
# Scripts inheriting from BaseScript must implement a method named "run".
# Command line parameters are available in the "args" variable.
# The script must return a Crossbeams::Responses object.
#
# Call a script like this:
#
#     RACK_ENV=production ruby scripts/base_script.rb EgScript one 2 three
#
# Where the first parameter is the script class and
# following parameters are args for the script itself.
#
# To get more visibility, use the DEBUG env var:
#
#     DEBUG=y RACK_ENV=production ruby scripts/base_script.rb EgScript one 2 three
#
# In scripts, the variable "debug_mode" will be set to true.

ENV['RACK_ENV'] ||= 'development'
require 'bundler'
Bundler.require(:default, ENV.fetch('RACK_ENV', 'development'))

require_relative '../config/environment'
require_relative '../config/app_const'
require_relative '../lib/crossbeams_errors'
require_relative '../lib/crossbeams_responses'
require_relative '../lib/error_mailer'

class BaseScript
  include Crossbeams::Responses
  attr_reader :args, :root_dir, :debug_mode

  def initialize(args)
    @args = args
    @root_dir = File.expand_path('../', __dir__)
    @debug_mode = !ENV['DEBUG'].nil?
    return unless debug_mode

    puts "Running #{self.class} in debug mode"
    puts "Args: #{args.inspect}"
    puts "Root dir: #{root_dir}"
    puts '---'
  end

  # Called when the script is run.
  # This in turn calls the inheriting class' run method.
  #
  # @return [exit status]
  def exec # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
    res = run
    if debug_mode
      puts '---'
      puts "Run response: #{res.inspect}"
      puts res.message if res.success && res.message
    end
    exit if res.success

    abort "Failed: #{res.message}"
  rescue StandardError => e
    puts "Exception: #{e.message}\n#{e.backtrace.join("\n")}" if debug_mode
    ErrorMailer.send_exception_email(e, subject: "Script #{self.class} failed", message: "Script args: #{args.inspect}\n")
    abort "Failed: #{e.message}\n#{e.backtrace.join("\n")}"
  end

  # Send an email based on an exception object.
  #
  # @param error [exception] the exception object.
  # @param subject [string] optional, the email subject.
  # @param message [string] optional, extra context to be included with the execption details in the mail body.
  # @return [void]
  def send_exception_email(error, subject: nil, message: nil)
    ErrorMailer.send_exception_email(error, subject, message)
  end

  # Send an error email with subject and message passed in describing an error condition..
  #
  # @param subject [string] optional, the email subject.
  # @param message [string] optional, the mail body.
  # @return [void]
  def send_error_email(subject: nil, message: nil, recipients: nil)
    ErrorMailer.send_error_email(subject: subject, message: message, recipients: recipients)
  end

  # Write out a dump of information for later inspection.
  # The first three parameters are used to name the logfile.
  # Log files are written to log/infodump.
  #
  # @param keyname [string] the general context of the action.
  # @param key [string] the specific context of the action.
  # @param description [string] A short description of the context (preferably without spaces)
  # @param information [string] the text to dump in the logfile.
  # @return [void]
  def log_infodump(keyname, key, description, information)
    dir = File.join(root_dir, 'log', 'infodump')
    Dir.mkdir(dir) unless Dir.exist?(dir)
    fn = File.join(dir, "#{keyname}_#{key}_#{Time.now.strftime('%Y_%m_%d_%H_%M_%S')}_#{description}.log")
    File.open(fn, 'w') { |f| f.puts information }
  end

  # Log the status of a record.
  #
  # @param table_name [Symbol, String] the name of the table.
  # @param id [Integer] the id of the record with the changed status.
  # @param status [String] the status to be logged.
  # @param comment [String] extra information about the status change.
  # @param user_name [String] the current user's name.
  def log_status(table_name, id, status, comment: nil, user_name: nil) # rubocop:disable Metrics/AbcSize
    # 1. UPSERT the current status.
    DB[Sequel[:audit][:current_statuses]].insert_conflict(target: %i[table_name row_data_id],
                                                          update: {
                                                            user_name: Sequel[:excluded][:user_name],
                                                            row_data_id: Sequel[:excluded][:row_data_id],
                                                            status: Sequel[:excluded][:status],
                                                            comment: Sequel[:excluded][:comment],
                                                            transaction_id: Sequel.function(:txid_current),
                                                            action_tstamp_tx: Time.now
                                                          }).insert(user_name: user_name,
                                                                    table_name: table_name.to_s,
                                                                    row_data_id: id,
                                                                    status: status.upcase,
                                                                    comment: comment)

    # 2. INSERT into log.
    DB[Sequel[:audit][:status_logs]].insert(user_name: user_name,
                                            table_name: table_name.to_s,
                                            row_data_id: id,
                                            status: status.upcase,
                                            comment: comment)
  end

  # Log the status of several records.
  #
  # @param table_name [Symbol] the name of the table.
  # @param in_ids [Array/Integer] the ids of the records with the changed status.
  # @param status [String] the status to be logged.
  # @param comment [String] extra information about the status change.
  # @param user_name [String] the current user's name.
  def log_multiple_statuses(table_name, in_ids, status, comment: nil, user_name: nil) # rubocop:disable Metrics/AbcSize
    ids = Array(in_ids)

    ids.each do |id|
      DB[Sequel[:audit][:current_statuses]].insert_conflict(target: %i[table_name row_data_id],
                                                            update: {
                                                              user_name: Sequel[:excluded][:user_name],
                                                              row_data_id: Sequel[:excluded][:row_data_id],
                                                              status: Sequel[:excluded][:status],
                                                              comment: Sequel[:excluded][:comment],
                                                              transaction_id: Sequel.function(:txid_current),
                                                              action_tstamp_tx: Time.now
                                                            }).insert(user_name: user_name,
                                                                      table_name: table_name.to_s,
                                                                      row_data_id: id,
                                                                      status: status.upcase,
                                                                      comment: comment)
    end

    items = []
    ids.each do |id|
      items << { user_name: user_name,
                 table_name: table_name.to_s,
                 row_data_id: id,
                 status: status.upcase,
                 comment: comment }
    end
    DB[Sequel[:audit][:status_logs]].multi_insert(items)
  end
end

class EgScript < BaseScript
  # Sample implementation of a run method.
  def run
    puts 'In EG'
    p root_dir
    p args
    # raise Crossbeams::InfoError, 'ScriptInfoError'
    # p DB[:users].get(:id)
    # raise 'Scriptbang'
    # failed_response('Did not work')
    ok_response
  end
end

Dir['./scripts/*.rb'].sort.each { |f| require f unless f.match?(/base_script/) }

klass = ARGV.shift
script = Module.const_get(klass).send(:new, ARGV)
script.exec
