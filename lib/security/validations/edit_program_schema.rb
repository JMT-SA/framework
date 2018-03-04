EditProgramSchema = Dry::Validation.Schema do
  required(:program_name).filled(:str?)
  required(:webapps).filled(:array?)
end
