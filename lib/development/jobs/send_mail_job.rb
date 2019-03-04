# frozen_string_literal: true

module DevelopmentApp
  class SendMailJob < BaseQueJob
    def run(options = {})
      mail = Mail.new do
        from    options.fetch(:from, AppConst::SYSTEM_MAIL_SENDER)
        to      options.fetch(:to)
        subject options.fetch(:subject)
        body    options.fetch(:body)
      end

      mail['cc'] = options[:cc] if options[:cc]

      process_attachments(mail, options)

      mail.deliver!
      finish
    end

    private

    def process_attachments(mail, options) # rubocop:disable Metrics/AbcSize
      (options[:attachments] || []).each do |rule|
        assert_attachment_ok!(rule)
        if rule[:path]
          raise "Unable to send mail with attachment \"#{rule[:path]}\" as it is not on disk" unless File.exist?(rule[:path])
          mail.add_file(rule[:path])
          next
        end

        next unless rule[:filename]
        config = { filename: rule[:filename], content: rule[:content] }
        config[:mime_type] = rule[:mime_type] if rule[:mime_type]
        mail.add_file(config)
      end
    end

    def assert_attachment_ok!(rule)
      keys = rule.keys.dup
      if keys.include?(:path)
        check_path!(keys)
      else
        check_filename!(keys)
      end
    end

    def check_path!(keys)
      _ = keys.delete(:path)
      raise ArgumentError, 'Mail attachment with file path cannot include other options' unless keys.empty?
    end

    def check_filename!(keys)
      keys.each do |key|
        raise ArgumentError, "Mail attachment has invalid option: #{key}" unless %i[filename content mime_type].include?(key)
      end
      raise ArgumentError, 'Mail attachment must have filename and content options' unless keys.include?(:filename) && keys.include?(:content)
    end
  end
end
