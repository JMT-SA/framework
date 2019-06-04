# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module SecurityApp
  class TestRegisteredMobileDeviceRepo < MiniTestWithHooks
    def test_for_selects
      assert_respond_to repo, :for_select_registered_mobile_devices
    end

    def test_crud_calls
      test_crud_calls_for :registered_mobile_devices, name: :registered_mobile_device, wrapper: RegisteredMobileDevice
    end

    private

    def repo
      RegisteredMobileDeviceRepo.new
    end
  end
end
