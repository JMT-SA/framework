# frozen_string_literal: true

module LabelApp
  class Printer < Dry::Struct
    attribute :id, Types::Integer
    attribute :printer_code, Types::String
    attribute :printer_name, Types::String
    attribute :printer_type, Types::String
    attribute :pixels_per_mm, Types::Integer
    attribute :printer_language, Types::String
    attribute :server_ip, Types::String
    attribute :printer_use, Types::String
  end
end
