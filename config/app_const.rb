# frozen_string_literal: true

# A class for defining global constants in a central place.
class AppConst # rubocop:disable Metrics/ClassLength
  def self.development?
    ENV['RACK_ENV'] == 'development'
  end

  # Any value that starts with y, Y, t or T is considered true.
  # All else is false.
  def self.check_true(val)
    val.match?(/^[TtYy]/)
  end

  # Take an environment variable and interpret it
  # as a boolean.
  def self.make_boolean(key, required: false)
    val = if required
            ENV.fetch(key)
          else
            ENV.fetch(key, 'f')
          end
    check_true(val)
  end

  # Client-specific code
  CLIENT_CODE = ENV.fetch('CLIENT_CODE')
  IMPLEMENTATION_OWNER = ENV.fetch('IMPLEMENTATION_OWNER')
  SHOW_DB_NAME = ENV.fetch('DATABASE_URL').rpartition('@').last
  URL_BASE = ENV.fetch('URL_BASE')
  APP_CAPTION = ENV.fetch('APP_CAPTION')
  STOCK_TAKE_ON_DATE = ENV.fetch('STOCK_TAKE_ON_DATE')

  PO_ACCOUNT_CODE = ENV['PO_ACCOUNT_CODE']
  PO_FIN_OBJECT_CODE = ENV['PO_FIN_OBJECT_CODE']
  GRN_CREDIT_NOTE_MAIL_RECIPIENTS = ENV['GRN_CREDIT_NOTE_MAIL_RECIPIENTS']

  # Constants for roles:
  ROLE_IMPLEMENTATION_OWNER = 'IMPLEMENTATION_OWNER'
  ROLE_CUSTOMER = 'CUSTOMER'
  ROLE_SUPPLIER = 'SUPPLIER'
  ROLE_TRANSPORTER = 'TRANSPORTER'

  # Routes that do not require login:
  BYPASS_LOGIN_ROUTES = [
    '/masterfiles/config/label_templates/published'
  ].freeze

  # Menu
  FUNCTIONAL_AREA_RMD = 'RMD'

  # Logging
  FIELDS_TO_EXCLUDE_FROM_DIFF = %w[label_json png_image].freeze

  # MesServer
  LABEL_SERVER_URI = ENV.fetch('LABEL_SERVER_URI')
  POST_FORM_BOUNDARY = 'AaB03x'

  # Labels
  SHARED_CONFIG_HOST_PORT = ENV.fetch('SHARED_CONFIG_HOST_PORT')
  LABEL_LOCATION_BARCODE = 'KR_PM_LOCATION' # From ENV? / Big config gem?
  LABEL_SKU_BARCODE = 'KR_PM_SKU' # From ENV? / Big config gem?
  LABEL_PUBLISH_NOTIFY_URLS = ENV.fetch('LABEL_PUBLISH_NOTIFY_URLS', '').split(',')
  BATCH_PRINT_MAX_LABELS = ENV.fetch('BATCH_PRINT_MAX_LABELS', 20).to_i
  PREVIEW_PRINTER_TYPE = ENV.fetch('PREVIEW_PRINTER_TYPE', 'zebra')

  # Printers
  PRINTER_USE_INDUSTRIAL = 'INDUSTRIAL'
  PRINTER_USE_OFFICE = 'OFFICE'

  PRINT_APP_LOCATION = 'Location'
  PRINT_APP_MR_SKU_BARCODE = 'Material Resource SKU Barcode'

  PRINTER_APPLICATIONS = [
    PRINT_APP_LOCATION,
    PRINT_APP_MR_SKU_BARCODE
  ].freeze

  # These will need to be configured per installation...
  BARCODE_PRINT_RULES = {
    location: { format: 'LC%d', fields: [:id] },
    sku: { format: 'SK%d', fields: [:sku_number] },
    delivery: { format: 'DN%d', fields: [:delivery_number] },
    tripsheet: { format: 'TS%d', fields: [:tripsheet_number] },
    stock_adjustment: { format: 'SA%d', fields: [:stock_adjustment_number] }
  }.freeze

  BARCODE_SCAN_RULES = [
    { regex: '^LC(\\d+)$', type: 'location', field: 'id' },
    { regex: '^(\\D\\D\\D)$', type: 'location', field: 'location_short_code' },
    { regex: '^(\\D\\D\\D)$', type: 'dummy', field: 'code' },
    { regex: '^SK(\\d+)', type: 'sku', field: 'sku_number' },
    { regex: '^DN(\\d+)', type: 'delivery', field: 'delivery_number' },
    { regex: '^TS(\\d+)', type: 'tripsheet', field: 'tripsheet_number' },
    { regex: '^SA(\\d+)', type: 'stock_adjustment', field: 'stock_adjustment_number' }
  ].freeze

  # Per scan type, per field, set attributes for displaying a lookup value below a scan field.
  # The key matches a key in BARCODE_PRINT_RULES. (e.g. :location)
  # The hash for that key is keyed by the value of the BARCODE_SCAN_RULES :field. (e.g. :id)
  # The rules for that field are: the table to read, the field to match the scanned value and the field to display in the form.
  # If a join is required, specify join: table_name and on: Hash of field on source table: field on target table.
  BARCODE_LOOKUP_RULES = {
    location: {
      id: { table: :locations, field: :id, show_field: :location_long_code },
      location_short_code: { table: :locations, field: :location_short_code, show_field: :location_long_code }
    },
    sku: {
      sku_number: { table: :mr_skus,
                    field: :sku_number,
                    show_field: :product_variant_code,
                    join: :material_resource_product_variants,
                    on: { id: :mr_product_variant_id } }
    }
  }.freeze

  # Que
  QUEUE_NAME = ENV.fetch('QUEUE_NAME', 'default')

  # Mail
  ERROR_MAIL_RECIPIENTS = ENV.fetch('ERROR_MAIL_RECIPIENTS')
  ERROR_MAIL_PREFIX = ENV.fetch('ERROR_MAIL_PREFIX')
  SYSTEM_MAIL_SENDER = ENV.fetch('SYSTEM_MAIL_SENDER')
  EMAIL_REQUIRES_REPLY_TO = make_boolean('EMAIL_REQUIRES_REPLY_TO')

  SALES_MAIL_RECIPIENTS = 'Sale Notification Recipients'
  USER_EMAIL_GROUPS = [SALES_MAIL_RECIPIENTS].freeze

  # Business Processes
  PROCESS_DELIVERIES = 'DELIVERIES'
  PROCESS_VEHICLE_JOBS = 'VEHICLE JOBS'
  PROCESS_ADHOC_TRANSACTIONS = 'ADHOC TRANSACTIONS'
  PROCESS_BULK_STOCK_ADJUSTMENTS = 'BULK STOCK ADJUSTMENTS'
  PROCESS_STOCK_TAKE = 'STOCK TAKE'
  PROCESS_STOCK_TAKE_ON = 'STOCK TAKE ON'
  PROCESS_STOCK_SALES = 'STOCK SALES'
  PROCESS_WASTE_SALES = 'WASTE SALES'
  PROCESS_WASTE_CREATED = 'WASTE CREATED'
  PROCESS_DESTROYED_FOR_WASTE = 'DESTROYED FOR WASTE'
  PROCESS_GOODS_RETURN = 'GOODS RETURN'
  PROCESS_SALES_ORDERS = 'SALES ORDERS'
  PROCESS_CONSUMPTION = 'CONSUMPTION'

  # Locations: Location Types
  LOCATION_TYPES_RECEIVING_BAY = 'RECEIVING BAY'
  LOCATION_TYPES_BUILDING = 'BUILDING'
  LOCATION_TYPES_DISPATCH = 'DISPATCH'
  LOCATIONS_PM = 'PM'
  LOCATIONS_CARTON_ASSEMBLY = ENV.fetch('LOCATIONS_CARTON_ASSEMBLY')

  ERP_PURCHASE_INVOICE_URI = ENV.fetch('ERP_PURCHASE_INVOICE_URI')
  ERP_SALES_INVOICE_URI = ENV.fetch('ERP_SALES_INVOICE_URI')
  ERP_BSA_JOURNAL_URI = ENV.fetch('ERP_BSA_JOURNAL_URI')

  BIG_ZERO = BigDecimal('0')
  # The maximum size of an integer in PostgreSQL
  MAX_DB_INT = 2_147_483_647

  # ISO 2-character country codes
  ISO_COUNTRY_CODES = %w[
    AF AL DZ AS AD AO AI AQ AG AR AM AW AU AT AZ BS BH BD BB BY BE BZ BJ
    BM BT BO BQ BA BW BV BR IO BN BG BF BI CV KH CM CA KY CF TD CL CN CX
    CC CO KM CD CG CK CR HR CU CW CY CZ CI DK DJ DM DO EC EG SV GQ ER EE
    SZ ET FK FO FJ FI FR GF PF TF GA GM GE DE GH GI GR GL GD GP GU GT GG
    GN GW GY HT HM VA HN HK HU IS IN ID IR IQ IE IM IL IT JM JP JE JO KZ
    KE KI KP KR KW KG LA LV LB LS LR LY LI LT LU MO MG MW MY MV ML MT MH
    MQ MR MU YT MX FM MD MC MN ME MS MA MZ MM NA NR NP NL NC NZ NI NE NG
    NU NF MP NO OM PK PW PS PA PG PY PE PH PN PL PT PR QA MK RO RU RW RE
    BL SH KN LC MF PM VC WS SM ST SA SN RS SC SL SG SX SK SI SB SO ZA GS
    SS ES LK SD SR SJ SE CH SY TW TJ TZ TH TL TG TK TO TT TN TR TM TC TV
    UG UA AE GB UM US UY UZ VU VE VN VG VI WF EH YE ZM ZW AX
  ].freeze

  RPT_INDUSTRY = ENV['RPT_INDUSTRY']
  JASPER_REPORTS_PATH = ENV['JASPER_REPORTS_PATH']

  MONTHS_OF_THE_YEAR = [
    %w[Jan 01],
    %w[Feb 02],
    %w[Mar 03],
    %w[Apr 04],
    %w[May 05],
    %w[Jun 06],
    %w[Jul 07],
    %w[Aug 08],
    %w[Sep 09],
    %w[Oct 10],
    %w[Nov 11],
    %w[Dec 12]
  ].freeze

  REPORT_YEARS = %w[2019 2020].freeze
end
