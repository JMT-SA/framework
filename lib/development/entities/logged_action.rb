# frozen_string_literal: true

module DevelopmentApp
  class LoggedAction < Dry::Struct
    attribute :event_id, Types::Int
    attribute :schema_name, Types::String
    attribute :table_name, Types::String
    attribute :row_data_id, Types::Int
  end
end
