# frozen_string_literal: true

module PackMaterialApp
  class MatresMasterListItem < Dry::Struct
    attribute :id, Types::Integer
    attribute :material_resource_master_list_id, Types::Integer
    attribute :short_code, Types::String
    attribute :long_name, Types::String
    attribute :description, Types::String
    attribute :active, Types::Bool
  end
end
