# frozen_string_literal: true

module DevelopmentApp
  class QueJob < Dry::Struct
    attribute :priority, Types::Integer
    attribute :run_at, Types::DateTime
    attribute :id, Types::Integer
    attribute :job_class, Types::String
    attribute :error_count, Types::Integer
    attribute :last_error_message, Types::String
    attribute :queue, Types::String
    attribute :last_error_backtrace, Types::String
    attribute :finished_at, Types::DateTime
    attribute :expired_at, Types::DateTime
    attribute :args, Types::Hash
    attribute :data, Types::Hash
  end
end
