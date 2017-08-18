FunctionalAreaSchema = Dry::Validation.Schema do
  required(:functional_area_name).filled(:str?)
end
