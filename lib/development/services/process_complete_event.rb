# frozen_string_literal: true

# rubocop:disable Security/Eval -- Need to use eval for ERUBI
module DevelopmentApp
  # Service to prepare an email for delivering via DevelopmentApp::SendMailJob.
  #
  # options can include:
  # :to
  # :from
  # :cc
  #
  # Further customisations can be made by modifying the  CONFIG constant for a particular table_name
  # - specify a query and modify the body/subject using ERB templating.
  class ProcessCompleteEvent < BaseService
    attr_reader :id, :table_name, :user_name, :options, :inflector

    def initialize(id, table_name, user_name, options)
      @id = id
      @table_name = table_name
      @user_name = user_name
      @options = options
      @inflector = Dry::Inflector.new
    end

    def call
      return if config.nil?

      create_instance_vars
      @table_text = inflector.humanize(inflector.singularize(table_name.to_s))
      DevelopmentApp::SendMailJob.enqueue(mail_opts)
    end

    private

    def subject_template
      eval(Erubi::Engine.new(config[:subject] || '<%=@table_text%> <%=@key%> has been completed').src)
    end

    def body_template
      eval(Erubi::Engine.new(config[:body] || "<%=@user_name%> has completed this <%=@table_text%>.\nPlease check and authorise or reject.").src)
    end

    def mail_opts
      opts = {
        to: options[:to] || config[:to],
        subject: subject_template,
        body: body_template
      }
      opts[:from] = options[:from] if options[:from]
      opts[:cc] = options[:cc] if options[:cc]
      opts
    end

    def create_instance_vars
      repo = DevelopmentRepo.new
      _, rows = repo.cols_and_rows_from_query(config[:query], id)
      keys = rows.first
      keys.each { |k, v| instance_variable_set("@#{k}", v) }
    end

    def config
      @config ||= CONFIG[table_name]
    end

    # other rules for to address - based on data...
    CONFIG = {
      labels: {
        to: 'james@nosoft.biz',
        query: 'SELECT label_name AS key FROM labels WHERE id = ?'
      }
    }.freeze
  end
end
# rubocop:enable Security/Eval
