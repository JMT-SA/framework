# frozen_string_literal: true

module DevelopmentApp
  class LoggedActionDetail < Dry::Struct
    attribute :id, Types::Int
    attribute :schema_name, Types::String
    attribute :table_name, Types::String
    attribute :row_data_id, Types::Int
    attribute :action, Types::String
    attribute :user_name, Types::String
    attribute :context, Types::String
    attribute :status, Types::String
  end
end
