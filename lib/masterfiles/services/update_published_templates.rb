# frozen_string_literal: true

module MasterfilesApp
  class UpdatePublishedTemplates < BaseService
    attr_reader :labels, :printer_type, :repo

    def initialize(params)
      @printer_type = params[:printer_type]
      @labels = params[:labels].select { |l| l[:variable_set] == 'Pack Material' }
    end

    def call
      return ok_response if labels.empty?

      @repo = LabelTemplateRepo.new
      res = update_label_templates
      return res unless res.success

      ok_response
    end

    private

    def update_label_templates
      repo.transaction do
        labels.each do |label_def|
          label_template = repo.find_label_template_by_name(label_def[:label_name])
          if label_template.nil?
            add_new_label_template(label_def)
          else
            update_label_template(label_template, label_def)
          end
        end
        repo.log_action(user_name: 'system', context: 'NSLD labels published')
      end
      ok_response
    end

    def add_new_label_template(label_def) # rubocop:disable Metrics/AbcSize
      app_names = label_def[:variables].first&.values
      app_names = app_names.first[:applications].first unless app_names.nil?
      id = repo.create_label_template(
        label_template_name: label_def[:label_name],
        description: label_def[:label_name],
        application: app_names || 'Unknown',
        variables: variables_list(label_def),
        variable_rules: variables_as_json(label_def)
      )
      repo.log_status('label_templates', id, 'CREATED', comment: 'from PUBLISH event', user_name: 'system')
    end

    def update_label_template(label_template, label_def)
      repo.update_label_template(
        label_template.id,
        variables: variables_list(label_def),
        variable_rules: variables_as_json(label_def)
      )
      repo.log_status('label_templates', label_template.id, 'VARIABLE_LIST_UPDATED', comment: 'from PUBLISH event', user_name: 'system')
    end

    def variables_as_json(label_def)
      repo.hash_for_jsonb_col(variables: label_def[:variables])
    end

    def variables_list(label_def)
      return nil if label_def[:variables].nil? || label_def[:variables].empty?

      repo.array_of_text_for_db_col(label_def[:variables].map { |v| v.keys.first.to_s })
    end
  end
end
__END__
{
  "publish_data": {
    "labels": [
      {
        "id": 38,
        "variables": [
          {
            "Location Barcode": {
              "group": "Locaton",
              "resolver": "BCD:location",
              "applications": [
                "Location",
                "Stock Adjustment"
              ]
            }
          },
          {
            "Location Description": {
              "group": "Locaton",
              "resolver": "location_description",
              "applications": [
                "Location",
                "Stock Adjustment"
              ]
            }
          },
          {
            "Location Long Code": {
              "group": "Locaton",
              "resolver": "location_long_code",
              "applications": [
                "Location",
                "Stock Adjustment"
              ]
            }
          },
          {
            "Location Short Code": {
              "group": "Locaton",
              "resolver": "location_short_code",
              "applications": [
                "Location",
                "Stock Adjustment"
              ]
            }
          }
        ],
        "label_name": "KR_PM_LOCATION",
        "variable_set": "Pack Material"
      }
    ],
    "printer_type": "Zebra"
  }
}
