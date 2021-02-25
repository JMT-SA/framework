# frozen_string_literal: true

module SecurityApp
  FunctionalAreaSchema = Dry::Schema.Params do
    required(:functional_area_name).filled(Types::StrippedString)
  end
end
