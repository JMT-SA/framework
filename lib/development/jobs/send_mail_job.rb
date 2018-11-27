# frozen_string_literal: true

module DevelopmentApp
  class SendMailJob < BaseQueJob
    # from, to, cc, subj, body, attachments: [{ file: xxx, name: xxx, mime: xx}, {...}]
    # def run(from: ENV['SYSTEM_MAIL_FROM'], to:, subject:, body:, options: {})
    def run(options = {})
      mail = Mail.new do
        from    options.fetch(:from, ENV['SYSTEM_MAIL_SENDER'])
        to      options.fetch(:to)
        subject options.fetch(:subject)
        body    options.fetch(:body)
      end
      mail['cc'] = options[:cc] if options[:cc]
      # ...and attachments
      # add_file '/full/path/to/somefile.png'
      mail.deliver!
      finish
    end
  end
end
