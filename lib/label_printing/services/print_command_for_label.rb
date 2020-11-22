# frozen_string_literal: true

module LabelPrintingApp
  # Apply an instance's values to a label template's variable rules and produce a print command string.
  class PrintCommandForLabel < BaseService
    include LabelContent

    attr_reader :label_name, :instance

    def initialize(label_name, instance)
      @label_name = label_name
      @instance = instance
      @supporting_data = {}
      raise ArgumentError, 'PrintCommandForLabel requires a label name' if label_name.nil?
    end

    def call
      lbl_required = fields_for_label
      field_positions = special_field_positions(lbl_required, %w[carton_label_id pick_ref pallet_number personnel_number FNC:iso_day FNC:iso_week FNC:iso_week_day FNC:current_date])
      vars = values_from(lbl_required)
      build_command_string(vars, field_positions)
    rescue Crossbeams::FrameworkError => e
      failed_response(e.message)
    end

    private

    def build_command_string(vars, field_positions) # rubocop:disable Metrics/AbcSize
      var_items = []
      vars.values.each_with_index do |v, i|
        var_items << if field_positions.keys.include?(i)
                       "<fvalue>#{format_special_field(field_positions[i])}</fvalue>"
                     else
                       "<fvalue>#{v}</fvalue>"
                     end
      end
      ar = ['<label><status>true</status>']
      ar << "<template>#{label_name}</template>"
      ar << '<quantity>1</quantity>'
      ar << var_items.join
      ar << "<lcd1>Label #{label_name}</lcd1>"
      ar << '<lcd2>Label printed...</lcd2>'
      ar << '<lcd3></lcd3><lcd4></lcd4><lcd5></lcd5><lcd6></lcd6>'
      ar << '<msg>Carton Label printed successfully</msg>'
      ar << '</label>'
      success_response('ok', OpenStruct.new(print_command: ar.join))
    end
  end
end
