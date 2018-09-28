# frozen_string_literal: true

module SecurityApp
  class ProgramFunction < Dry::Struct
    attribute :id, Types::Integer
    attribute :program_id, Types::Integer
    attribute :program_function_name, Types::String
    attribute :group_name, Types::String
    attribute :url, Types::String
    attribute :program_function_sequence, Types::Integer
    attribute :restricted_user_access, Types::Bool
    attribute :active, Types::Bool
    attribute :show_in_iframe, Types::Bool
  end
end
