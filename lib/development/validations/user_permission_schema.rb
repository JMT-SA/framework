# frozen_string_literal: true

module DevelopmentApp
  UserPermissionSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    required(:security_group_id, :integer).filled(:int?)
  end
end
