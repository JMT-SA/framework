# frozen_string_literal: true

module DevelopmentApp
  class ScaffoldNewContract < Dry::Validation::Contract
    params do
      required(:table).filled(:string)
      optional(:other).maybe(Types::StrippedString)
      required(:program).filled(Types::StrippedString)
      required(:label_field).maybe(Types::StrippedString)
      required(:short_name).filled(Types::StrippedString)
      required(:shared_repo_name).maybe(Types::StrippedString)
      required(:shared_factory_name).maybe(Types::StrippedString)
      required(:nested_route_parent).maybe(:string)
      required(:new_from_menu).maybe(:bool)
      required(:jobs).maybe(:string)
      required(:services).maybe(:string)
      required(:applet).filled(Types::StrippedString)
    end

    rule(:other, :applet) do
      key.failure 'must be filled in' if values[:applet] == 'other' && values[:other].nil?
    end
  end
end
