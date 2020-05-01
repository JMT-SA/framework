# frozen_string_literal: true

module LabelPrintingApp
  # Apply an instance's values to a label template's variable rules and produce a preview image of it.
  class PreviewLabel < BaseService
    include LabelContent

    attr_reader :label_name, :instance

    def initialize(label_name, instance)
      @label_name = label_name
      @instance = instance
      @supporting_data = {}
      raise ArgumentError if label_name.nil?
    end

    def call
      lbl_required = fields_for_label
      vars = values_from(lbl_required)
      messerver_preview(vars)
    rescue Crossbeams::FrameworkError => e
      failed_response(e.message)
    end

    private

    def messerver_preview(vars)
      mes_repo = MesserverApp::MesserverRepo.new
      res = mes_repo.preview_published_label(label_name, vars)
      return res unless res.success

      success_response('ok', OpenStruct.new(fname: 'preview_lbl', body: res.instance))
    end
  end
end
