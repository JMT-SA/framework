# frozen_string_literal: true

module DevelopmentApp
  class ExportDataEventLog < Dry::Struct
    attribute :id, Types::Integer
    attribute :export_key, Types::String
    attribute :started_at, Types::DateTime
    attribute :event_log, Types::String
    attribute :complete, Types::Bool
    attribute :completed_at, Types::DateTime
    attribute :failed, Types::Bool
    attribute :error_message, Types::String
  end
end
