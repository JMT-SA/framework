ProgramSchema = Dry::Validation.Schema do
  required(:program_name).filled(:str?)
end
