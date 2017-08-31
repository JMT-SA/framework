SecurityPermissionSchema = Dry::Validation.Schema do
  required(:security_permission).filled(:str?)
end
