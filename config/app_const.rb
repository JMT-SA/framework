# frozen_string_literal: true

# A class for defining global constants in a central place.
class AppConst
  # Constants for roles:
  ROLE_IMPLEMENTATION_OWNER = 'IMPLEMENTATION_OWNER'
  ROLE_CUSTOMER = 'CUSTOMER'
  ROLE_SUPPLIER = 'SUPPLIER'
  ROLE_TRANSPORTER = 'TRANSPORTER'

  # Menu
  FUNCTIONAL_AREA_RMD = 'RMD'

  # MesServer
  LABEL_SERVER_URI = ENV.fetch('LABEL_SERVER_URI')
  POST_FORM_BOUNDARY = 'AaB03x'

  # Labels
  LABEL_LOCATION_BARCODE = 'KR_PM_LOCATION' # From ENV? / Big config gem?
  LABEL_SKU_BARCODE = 'KR_PM_SKU' # From ENV? / Big config gem?
end
