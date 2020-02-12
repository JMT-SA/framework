# frozen_string_literal: true

class BaseQueJob < Que::Job
  include Crossbeams::MessageBus

  self.queue = AppConst::QUEUE_NAME

  Que.error_notifier = proc do |error, job|
    p ">>> ERROR FOR JOB #{job}"
    puts error.full_message
    p "Err count: #{job[:error_count]}"

    # Hand off to mailer on first trigger of error. Obviously do not send an email if the error arose during email sending.
    do_not_send = job[:error_count].positive? || job[:job_class] == 'DevelopmentApp::SendMailJob'
    ErrorMailer.send_exception_email(error, subject: "Job #{job[:job_class]} error: #{error.message}", job_context: job) unless do_not_send

    # Do whatever you want with the error object or job row here. Note that the
    # job passed is not the actual job object, but the hash representing the job
    # row in the database, which looks like:

    # {
    #   :priority => 100,
    #   :run_at => "2017-09-15T20:18:52.018101Z",
    #   :id => 172340879,
    #   :job_class => "TestJob",
    #   :error_count => 0,
    #   :last_error_message => nil,
    #   :queue => "default",
    #   :last_error_backtrace => nil,
    #   :finished_at => nil,
    #   :expired_at => nil,
    #   :args => [],
    #   :data => {}
    # }

    # This is done because the job may not have been able to be deserialized
    # properly, if the name of the job class was changed or the job class isn't
    # loaded for some reason. The job argument may also be nil, if there was a
    # connection failure or something similar.
  end

  def handle_error(error)
    # case error
    # when TemporaryError then retry_in 10.seconds
    # when PermanentError then expire
    # else super # Default (exponential backoff) behavior.
    # end
    super
  end

  def log_level(elapsed)
    if elapsed > 60
      # This job took over a minute! We should complain about it!
      :warn
    elsif elapsed > 30
      # A little long, but no big deal!
      :info
    else
      :debug
      # # This is fine, don't bother logging at all.
      # false
    end
  end

  # For some jobs, it is crucial that instances follow one another
  # and they do not run in parallel with themselves.
  # They can run in parallel with other jobs, though.
  #
  # To make a job run "one-at-a-time", override this method and return
  # a string to be used as the lock file.
  def single_instance_job
    nil
  end

  def lock_file
    @lock_file ||= File.join(ENV['ROOT'], 'tmp', 'job_locks', ".#{single_instance_job}.lck")
  end

  # Before a job executes, check if onother instance of the same job is busy.
  def lock_single_instance
    return if single_instance_job.nil?

    retry_in(30) if File.exist?(lock_file)
    FileUtils.touch(lock_file)
  end

  # After a job executes, remove the lock file if it exists.
  def clear_single_instance
    return if single_instance_job.nil?

    File.delete(lock_file) if File.exist?(lock_file)
  end

  # Is there a job of this class enqueued including these parameters?
  def self.enqueued_with_args?(*args)
    jsonb_col = Sequel.pg_jsonb_op(:args)
    !DB[:que_jobs]
      .where(job_class: name)
      .where(jsonb_col.contains(Sequel.pg_jsonb(args)))
      .where(finished_at: nil)
      .where(expired_at: nil)
      .count.nonzero?.nil?
  end

  # Is there a job of this class enqueued with these parameters?
  def self.enqueued_with_exact_args?(*args)
    !DB[:que_jobs]
      .where(job_class: name)
      .where(args: Sequel.pg_jsonb(args))
      .where(finished_at: nil)
      .count.nonzero?.nil?
  end
end
