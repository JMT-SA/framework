# frozen_string_literal: true

module MasterfilesApp
  LabelTemplatePublishSchema = Dry::Schema.Params do
    required(:printer_type).filled(Types::StrippedString)
    required(:labels).array(:hash) do
      required(:id).filled(:integer)
      required(:label_name).filled(Types::StrippedString)
      required(:variable_set).filled(Types::StrippedString)
      required(:variables).maybe(:array) # { each(filled? > hash) }
    end
  end

  LabelTemplatePublishInnerSchema = Dry::Schema.Params do
    required(:group).filled(Types::StrippedString)
    required(:resolver).filled(Types::StrippedString)
    required(:group).filled(Types::StrippedString)
    required(:applications).filled(:array, min_size?: 1).each(:string)
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
