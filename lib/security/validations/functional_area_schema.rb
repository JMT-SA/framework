# frozen_string_literal: true

module SecurityApp
  FunctionalAreaSchema = Dry::Validation.Schema do
    required(:functional_area_name).filled(:str?)
  end
end
