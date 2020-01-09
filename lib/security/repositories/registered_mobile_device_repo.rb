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

    crud_calls_for :registered_mobile_devices, name: :registered_mobile_device # , wrapper: RegisteredMobileDevice

    def find_registered_mobile_device(id)
      find_with_association(:registered_mobile_devices, id,
                            wrapper: RegisteredMobileDevice,
                            parent_tables: [{ parent_table: :program_functions,
                                              foreign_key: :start_page_program_function_id,
                                              columns: [:program_function_name],
                                              flatten_columns: { program_function_name: :start_page } }])
      # DB[:registered_mobile_devices].left_join(:program_functions, id: :start_page_program_function_id)
      #                               .select(Sequel[:registered_mobile_devices].*, Sequel[:program_functions][:program_function_name])
      #                               .where(Sequel[:registered_mobile_devices][:id] => id).first
    end

    # Is the given ip address for an active registered mobile device?
    #
    # If it is, pass the start page url back as the instance.
    #
    # @param ip_address [string] the ip address to check.
    # @return [Crossbeams::Response] a success response will include the start page url (could be nil) as the instance.
    def ip_address_is_rmd?(ip_address)
      hash = DB[:registered_mobile_devices].left_join(:program_functions, id: :start_page_program_function_id)
                                           .select(:url, :scan_with_camera, :hybrid_device)
                                           .where(ip_address: ip_address)
                                           .where(Sequel[:registered_mobile_devices][:active] => true)
                                           .first
      if hash
        success_response('Called from a RMD', OpenStruct.new(hash))
      else
        failed_response('Not a Remote Mobile Device')
      end
    end

    def find_by_ip_address(ip_address)
      id = DB[:registered_mobile_devices].where(ip_address: ip_address).get(:id)
      if id.nil?
        nil
      else
        find_registered_mobile_device(id)
      end
    end
  end
end
