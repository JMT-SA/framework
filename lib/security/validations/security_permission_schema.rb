# frozen_string_literal: true

module SecurityApp
  SecurityPermissionSchema = Dry::Schema.Params do
    required(:security_permission).filled(Types::StrippedString)
  end
end
