# frozen_string_literal: true

# List of all required environment variables with descriptions.
class EnvVarRules # rubocop:disable Metrics/ClassLength
  OPTIONAL = [
    { DONOTLOGSQL: 'Dev mode: do not log SQL calls' },
    { LOGSQLTOFILE: 'Dev mode: separate SQL calls out of logs and write to file "log/sql.log"' },
    { LOGFULLMESSERVERCALLS: 'Dev mode: Log full payload of HTTP calls to MesServer. Only do this if debugging.' },
    { RUN_FOR_RMD: 'Dev mode: Force the server to act as if it is being called from a Registered Mobile Device' },
    { NO_ERR_HANDLE: 'Dev mode: Do not use the error handling built into the framework. Can be useful to debug without mail sending in the output.' },
    { PO_ACCOUNT_CODE: 'Purchase Order Account Code Default value for new PO.' },
    { PO_FIN_OBJECT_CODE: 'Purchase Order Finance Object Code Default value for new PO.' }
  ].freeze

  NO_OVERRIDE = [
    { RACK_ENV: 'This is set to "development" in the .env file and set to "production" by deployment settings.' },
    { APP_CAPTION: 'The application name to display in web pages.' },
    { DATABASE_NAME: 'The name of the database. This is mostly used to derive the test database name.' },
    { QUEUE_NAME: 'The name of the job Que.' }
  ].freeze

  CAN_OVERRIDE = [
    { DATABASE_URL: 'Database connection string in the format "postgres://USER:PASSS@HOST:PORT/DATABASE_NAME".' },
    { IMPLEMENTATION_OWNER: 'The name of the implementation client.' },
    { SHARED_CONFIG_HOST_PORT: 'IP address of shared_config in the format HOST:PORT' },
    { CHRUBY_STRING: 'The version of chruby used in development. Used in Rake tasks.' }
  ].freeze

  MUST_OVERRIDE = [
    { LABEL_SERVER_URI: 'HTTP address of MesServer in the format http://IP:2080/ NOTE: the trailing "/" is required.' },
    { JASPER_REPORTING_ENGINE_PATH: 'Full path to dir containing JasperReportPrinter.jar' },
    { JASPER_REPORTS_PATH: "Full path to client's Jasper report definitions." },
    { SYSTEM_MAIL_SENDER: 'Email address for "FROM" address in the format NAME<email>' },
    { ERROR_MAIL_PREFIX: 'Prefix to be placed in subject of emails sent from exceptions.' },
    { ERROR_MAIL_RECIPIENTS: 'Comma-separated list of recipients of exception emails.' },
    { CLIENT_CODE: 'Short, lowercase code to identify the implementation client. Used e.g. in defining per-client behaviour.' },
    { ERP_PURCHASE_INVOICE_URI: 'Url to call to post ERP purchase invoice to accounting system.' }
  ].freeze

  def print
    puts <<~STR
      -----------------------------
      --- ENVIRONMENT VARIABLES ---
      -----------------------------
      - Certain environment variables are fixed in the .env file.
      - Some of them can be overridden in the .env.local file. These are effectively the client settings.
      - Others are just available to set temporarily when running in development.

      No need to change these variable settings:
      ==========================================
      #{format(NO_OVERRIDE)}

      These variable settings can be changed in .env.local:
      =====================================================
      #{format(CAN_OVERRIDE)}

      These variable settings MUST be changed in .env.local:
      ======================================================
      #{format(MUST_OVERRIDE)}

      These variable settings can be set on the fly in development mode:
      e.g. "NO_ERR_HANDLE=y rackup"
      ==================================================================
      #{format(OPTIONAL)}
    STR
  end

  def root_path
    @root_path ||= File.expand_path('..', __dir__)
  end

  def env_keys
    envs = File.readlines(File.join(root_path, '.env'))
    ar = []
    envs.each { |e| ar << e.split('=').first unless e.strip.start_with?('#') }
    ar
  end

  def local_keys
    envs = File.readlines(File.join(root_path, '.env.local'))
    ar = []
    envs.each { |e| ar << e.split('=').first unless e.strip.start_with?('#') }
    ar
  end

  def existing
    @existing ||= (env_keys + local_keys).uniq
  end

  def format(array)
    array.map { |var| "#{var.keys.first.to_s.ljust(25)} : #{var.values.first}" }.join("\n")
  end

  def validate
    validation_check(NO_OVERRIDE, 'Must be present in ".env"')
    validation_check(CAN_OVERRIDE, 'Must be present in ".env" or ".env.local"')
    validation_check(MUST_OVERRIDE, 'Must be present in ".env.local"')
    puts "\nValidation complete"
  end

  def missing_check(array)
    msg = []
    array.each do |env|
      msg << "- Missing: #{env.keys.first} (#{env.values.first})" unless existing.include?(env.keys.first.to_s)
    end
    msg
  end

  def validation_check(array, desc)
    msg = missing_check(array)
    puts msg.empty? ? "#{desc} - OK" : desc
    puts msg.join("\n") unless msg.empty?
  end

  def add_missing_to_local
    to_add = []
    MUST_OVERRIDE.each do |env|
      k = env.keys.first.to_s
      v = env.values.first
      unless local_keys.include?(k)
        to_add << "# #{k}=#{v}\n"
        puts "Adding: #{k} (#{v})"
      end
    end

    update_local_file(to_add) unless to_add.empty?
  end

  def update_local_file(to_add)
    File.open(File.join(root_path, '.env.local'), 'a') { |f| to_add.each { |a| f << a } }
    puts "\nUpdated \".env.local\" - please modify (current contents are shown here):\n\n"
    puts File.read(File.join(root_path, '.env.local'))
  end
end
