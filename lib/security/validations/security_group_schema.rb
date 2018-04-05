# frozen_string_literal: true

module SecurityApp
  SecurityGroupSchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    required(:security_group_name, Types::StrippedString).filled(:str?)
  end
end
