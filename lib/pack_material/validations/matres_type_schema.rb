# frozen_string_literal: true

module PackMaterialApp
  MatresTypeSchema = Dry::Validation.Params do
    optional(:id).filled(:int?)
    required(:material_resource_domain_id).filled(:int?)
    required(:type_name).filled(:str?)
    required(:short_code, Types::StrippedString).filled(:str?)
    required(:description, Types::StrippedString).maybe(:str?)
    optional(:measurement_units, Types::IntArray).maybe { each(:int?) }
  end

  MatresTypeUnitSchema = Dry::Validation.Params do
    required(:unit_of_measure).filled(:str?)
  end
end
