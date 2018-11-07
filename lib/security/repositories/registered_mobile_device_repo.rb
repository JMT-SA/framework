# frozen_string_literal: true

module SecurityApp
  class RegisteredMobileDeviceRepo < BaseRepo
    build_for_select :registered_mobile_devices,
                     label: :ip_address,
                     value: :id,
                     order_by: :ip_address
    build_inactive_select :registered_mobile_devices,
                          label: :ip_address,
                          value: :id,
                          order_by: :ip_address

    crud_calls_for :registered_mobile_devices, name: :registered_mobile_device, wrapper: RegisteredMobileDevice
  end
end
