# frozen_string_literal: true

module SecurityApp
  RegisteredMobileDeviceSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:ip_address).filled(:string)
    required(:start_page_program_function_id).maybe(:integer)
    optional(:active).filled(:bool)
    required(:scan_with_camera).filled(:bool)
    required(:hybrid_device).filled(:bool)
  end
end
