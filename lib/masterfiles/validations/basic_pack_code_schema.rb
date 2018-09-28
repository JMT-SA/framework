# frozen_string_literal: true

module MasterfilesApp
  BasicPackCodeSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:basic_pack_code, Types::StrippedString).filled(:str?)
    required(:description, Types::StrippedString).maybe(:str?)
    required(:length_mm, :integer).maybe(:int?)
    required(:width_mm, :integer).maybe(:int?)
    required(:height_mm, :integer).maybe(:int?)
  end
end
