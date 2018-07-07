# frozen_string_literal: true

module DevelopmentApp
  UserPermissionSchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    required(:security_group_id, :int).filled(:int?)
  end
end
