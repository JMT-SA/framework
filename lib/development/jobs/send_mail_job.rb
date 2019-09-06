# frozen_string_literal: true

module DevelopmentApp
  class SendMailJob < BaseQueJob
    def run(options = {}) # rubocop:disable Metrics/AbcSize
      from_mail = resolve_sender(options[:from])

      mail = Mail.new do
        from    from_mail
        to      options.fetch(:to)
        subject options.fetch(:subject)
        body    options.fetch(:body)
      end

      cc_and_reply(mail, options)

      process_attachments(mail, options)

      mail.deliver!
      send_bus_message("Mail sent: '#{options[:subject]}'", target_user: options[:notify_user]) if options[:notify_user]
      finish
    end

    private

    # Some email servers will block a user from sending to certain addresses.
    # If that is the case, the FROM address is set to the system email sender
    # (which does have permission to send emails) and the REPLY-TO is set to
    # the user's email address so that the recipient can reply to the correct
    # email address.
    def resolve_sender(from)
      return AppConst::SYSTEM_MAIL_SENDER if from.nil?

      if AppConst::EMAIL_REQUIRES_REPLY_TO
        AppConst::SYSTEM_MAIL_SENDER
      else
        from
      end
    end

    def cc_and_reply(mail, options)
      mail['cc'] = options[:cc] if options[:cc]
      mail['reply_to'] = options[:from] if options[:from] && AppConst::EMAIL_REQUIRES_REPLY_TO
    end

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
