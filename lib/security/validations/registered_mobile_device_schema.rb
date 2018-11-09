# frozen_string_literal: true

module SecurityApp
  RegisteredMobileDeviceSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:ip_address, :string).filled(:str?)
    required(:start_page_program_function_id, :integer).maybe(:int?)
    optional(:active, :bool).filled(:bool?)
    required(:scan_with_camera, :bool).filled(:bool?)
  end
end
