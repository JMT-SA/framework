ProgramFunctionCreateSchema = Dry::Validation.Form do
  required(:program_function_name).filled(:str?)
  required(:url).filled(:str?)
  required(:program_function_sequence).filled(:int?)
  required(:program_id).filled(:int?) # Hidden parameter
  required(:group_name).maybe(:str?)
  required(:restricted_user_access).filled(:bool?)
  required(:active).filled(:bool?)
end
