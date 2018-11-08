# frozen_string_literal: true

module SecurityApp
  class RegisteredMobileDevice < Dry::Struct
    attribute :id, Types::Integer
    attribute :ip_address, Types::String
    attribute :start_page_program_function_id, Types::Integer
    attribute :active, Types::Bool
  end
end
