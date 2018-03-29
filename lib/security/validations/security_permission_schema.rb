# frozen_string_literal: true

module SecurityApp
  SecurityPermissionSchema = Dry::Validation.Schema do
    required(:security_permission).filled(:str?)
  end
end
