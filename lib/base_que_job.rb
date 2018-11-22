# frozen_string_literal: true

class BaseQueJob < Que::Job
  Que.error_notifier = proc do |error, job|
    # Hand off to mailer...
    p ">>> ERROR FOR JOB #{job[:id]}"
    p error.message

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
end
