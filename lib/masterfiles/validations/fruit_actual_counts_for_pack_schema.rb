# frozen_string_literal: true

module MasterfilesApp
  FruitActualCountsForPackSchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    optional(:id, :int).filled(:int?)
    required(:std_fruit_size_count_id, :int).filled(:int?)
    required(:basic_pack_code_id, :int).filled(:int?)
    required(:standard_pack_code_id, :int).filled(:int?)
    required(:actual_count_for_pack, :int).filled(:int?)
    required(:size_count_variation, Types::StrippedString).filled(:str?)
  end
end
