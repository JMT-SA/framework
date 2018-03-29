# frozen_string_literal: true

module SecurityApp
  SecurityGroupSchema = Dry::Validation.Schema do
    required(:security_group_name).filled(:str?)
  end
end
