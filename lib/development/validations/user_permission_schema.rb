# frozen_string_literal: true

module DevelopmentApp
  UserPermissionSchema = Dry::Schema.Params do
    required(:security_group_id).filled(:integer)
  end
end
