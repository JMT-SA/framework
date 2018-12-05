# frozen_string_literal: true

# Helper for barcode-related tasks.
class BarcodeProcessing
  # Take a field and format it for barcode printing.
  #
  # @param instance [Hash, DryType, OpenStruct] - the entity or hash that contains required values.
  # @param field [string] - the field to be formatted.
  # @return [string] - the formatted barcode string ready for printing.
  def make_barcode(instance, field)
    fmt_str = AppConst::BARCODE_PRINT_RULES[field.to_sym][:format]
    raise ArgumentError, "There is no BARCODE PRINT RULE for #{field}" if fmt_str.nil?

    vals = AppConst::BARCODE_PRINT_RULES[field.to_sym][:fields].map { |f| instance[f] }
    format(fmt_str, *vals)
  end
end
