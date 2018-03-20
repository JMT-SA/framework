ProgramFunctionSchema = Dry::Validation.Form do
  required(:program_function_name).filled(:str?)
  required(:url).filled(:str?)
  required(:program_function_sequence).filled(:int?)
  required(:group_name).maybe(:str?)
  required(:restricted_user_access).filled(:bool?)
  required(:active).filled(:bool?)
  optional(:show_in_iframe).filled(:bool?)
  optional(:program_id).filled(:int?)
end
