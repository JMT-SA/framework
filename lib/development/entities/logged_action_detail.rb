# frozen_string_literal: true

module DevelopmentApp
  class LoggedActionDetail < Dry::Struct
    attribute :id, Types::Integer
    attribute :transaction_id, Types::Integer
    attribute :action_tstamp_tx, Types::DateTime
    attribute :user_name, Types::String
    attribute :context, Types::String
    attribute :route_url, Types::String
    attribute :request_ip, Types::String
  end
end
