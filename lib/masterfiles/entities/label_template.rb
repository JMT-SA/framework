# frozen_string_literal: true

module MasterfilesApp
  class LabelTemplate < Dry::Struct
    attribute :id, Types::Integer
    attribute :label_template_name, Types::String
    attribute :description, Types::String
    attribute :application, Types::String
    attribute :variables, Types::Array.default([].freeze)
    attribute :variable_rules, Types::JSON::Hash
    attribute :active, Types::Bool
  end
end
