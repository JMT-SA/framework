# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module DevelopmentApp
  class TestSendMailJob < Minitest::Test
    def teardown
      Mail::TestMailer.deliveries.clear
    end

    def test_basics
      job = DevelopmentApp::SendMailJob.new
      job.run(to: 'fred@place.com', subject: 'Mail to test', body: 'A letter')
      assert_equal 1, Mail::TestMailer.deliveries.length
      mail = Mail::TestMailer.deliveries.first
      assert AppConst::SYSTEM_MAIL_SENDER.include?(mail.from.first)
      assert_equal 'fred@place.com', mail.to.first
      assert_equal 'Mail to test', mail.subject
      assert_equal 'A letter', mail.decoded
    end

    def test_from
      job = DevelopmentApp::SendMailJob.new
      AppConst.stub_const(:EMAIL_REQUIRES_REPLY_TO, false) do
        job.run(from: 'john@place.com', to: 'fred@place.com', subject: 'Mail to test', body: 'A letter')
      end
      assert_equal 1, Mail::TestMailer.deliveries.length
      mail = Mail::TestMailer.deliveries.first
      assert_equal 'john@place.com', mail.from.first
    end

    def test_from_when_reply_to
      job = DevelopmentApp::SendMailJob.new
      AppConst.stub_const(:EMAIL_REQUIRES_REPLY_TO, true) do
        job.run(from: 'john@place.com', to: 'fred@place.com', subject: 'Mail to test', body: 'A letter')
      end
      assert_equal 1, Mail::TestMailer.deliveries.length
      mail = Mail::TestMailer.deliveries.first
      assert AppConst::SYSTEM_MAIL_SENDER.include?(mail.from.first)
      assert_equal 'john@place.com', mail.reply_to.first
    end

    def test_cc
      job = DevelopmentApp::SendMailJob.new
      job.run(cc: 'john@place.com', to: 'fred@place.com', subject: 'Mail to test', body: 'A letter')
      assert_equal 1, Mail::TestMailer.deliveries.length
      mail = Mail::TestMailer.deliveries.first
      assert_equal 'john@place.com', mail.cc.first
    end

    def test_bad_attachment
      job = DevelopmentApp::SendMailJob.new
      attachments = [{ path: '/a/path', filename: 'a_file' },
                     { filename: 'a_file' },
                     { filename: 'a_file', content: 'ATTACHME', spurious: 'this should not be here' },
                     { content: 'ATTACHME' }]
      attachments.each do |rule|
        assert_raises(ArgumentError, "Arg err not raised for #{rule}") { job.run(to: 'fred@place.com', subject: 'Mail to test', body: 'A letter', attachments: [rule]) }
      end
    end

    def test_ok_attachment
      job = DevelopmentApp::SendMailJob.new
      attachments = [{ path: __FILE__ },
                     { filename: 'a_file', content: 'ATTACHME' }]
      attachments.each do |rule|
        job.run(to: 'fred@place.com', subject: 'Mail to test', body: 'A letter', attachments: [rule])
        assert_equal 1, Mail::TestMailer.deliveries.length
        mail = Mail::TestMailer.deliveries.first
        assert mail.multipart?
        Mail::TestMailer.deliveries.clear
      end
    end

    def test_multiple
      job = DevelopmentApp::SendMailJob.new
      job.run(to: ['fred@place.com', 'john@place.com'], subject: 'Mail to test', body: 'A letter')
      assert_equal 1, Mail::TestMailer.deliveries.length
      mail = Mail::TestMailer.deliveries.first
      assert_equal 'fred@place.com', mail.to.first
      assert_equal 'john@place.com', mail.to.last
    end

    def test_multiple_with_names
      job = DevelopmentApp::SendMailJob.new
      job.run(to: ['Fred <fred@place.com>', 'John <john@place.com>'], subject: 'Mail to test', body: 'A letter')
      assert_equal 1, Mail::TestMailer.deliveries.length
      mail = Mail::TestMailer.deliveries.first
      assert_equal 'fred@place.com', mail.to.first
      assert_equal 'john@place.com', mail.to.last
    end
  end
end
