# frozen_string_literal: true

module SecurityApp
  SecurityPermissionSchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    required(:security_permission, Types::StrippedString).filled(:str?)
  end
end
