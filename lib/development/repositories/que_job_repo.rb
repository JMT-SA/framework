# frozen_string_literal: true

module DevelopmentApp
  class QueJobRepo < BaseRepo
    crud_calls_for :que_jobs, name: :que_job, wrapper: QueJob, exclude: %i[create update delete]

    def que_status
      Que.job_stats
    end
  end
end
