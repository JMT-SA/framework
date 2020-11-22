# frozen_string_literal: true

module SecurityApp
  SecurityGroupSchema = Dry::Schema.Params do
    required(:security_group_name).filled(Types::StrippedString)
  end
end
