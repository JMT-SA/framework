# frozen_string_literal: true

module MasterfilesApp
  LabelTemplatePublishSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    # required(:publish_data) do
    #   schema do
    required(:printer_type, Types::StrippedString).filled(:str?)
    required(:labels).each do
      schema do
        required(:id, :integer).filled(:int?)
        required(:label_name, Types::StrippedString).filled(:str?)
        required(:variable_set, Types::StrippedString).filled(:str?)
        required(:variables, :array).maybe(:array?) # { each(filled? > hash) }
      end
      #   end
      # end
    end
  end

  LabelTemplatePublishInnerSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    required(:group, Types::StrippedString).filled(:str?)
    required(:resolver, Types::StrippedString).filled(:str?)
    required(:group, Types::StrippedString).filled(:str?)
    required(:applications, :array).filled(:array?, min_size?: 1) { each(:str?) }
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
      {
        printer_type: 'Zebra',
        labels: [
          {
            id: 123,
            label_name: 'LOCATION_ID',
            variable_set: 'CMS',
            variables:
            [
              {
                'Location barcode' => {
                  group: 'Location',
                  resolver: 'BCD:location',
                  applications: ['Location', 'Stock Adjustment']
                }
              }
            ]
          }
        ]
      }

{ printer_type: 'Zebra', labels: [ { id: 32, label_name: 'LBL', variable_set: 'CMS', variables: [ { 'CustomValue' => { group: 'Locaton', resolver: 'BCD:location', applications: ['Location', 'Stock Adjustment'] } } ] } ] }

inner = { group: 'Locaton', resolver: 'BCD:location', applications: ['Location', 'Stock Adjustment'] }
