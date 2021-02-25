# frozen_string_literal: true

module MasterfilesApp
  RegionSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:destination_region_name).filled(Types::StrippedString)
  end
end
