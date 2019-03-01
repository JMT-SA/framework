# frozen_string_literal: true

module LabelApp
  class PrinterApplication < Dry::Struct
    attribute :id, Types::Integer
    attribute :printer_id, Types::Integer
    attribute :application, Types::String
    attribute :active, Types::Bool
    attribute :printer_code, Types::String
    attribute :printer_name, Types::String
    attribute :default_printer, Types::Bool
  end
end
