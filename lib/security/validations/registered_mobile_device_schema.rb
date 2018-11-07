# frozen_string_literal: true

module SecurityApp
  RegisteredMobileDeviceSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    # required(:ip_address, Types::??? (ipaddr)).filled(Types::??? (ipaddr))
    required(:ip_address, :string).filled(:str?)
    required(:start_page_program_function_id, :integer).maybe(:int?)
  end
end
