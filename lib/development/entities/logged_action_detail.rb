# frozen_string_literal: true

module DevelopmentApp
  class LoggedActionDetail < Dry::Struct
    attribute :id, Types::Int
    attribute :transaction_id, Types::Int
    attribute :action_tstamp_tx, Types::DateTime
    attribute :user_name, Types::String
    attribute :context, Types::String
    attribute :route_url, Types::String
  end
end
