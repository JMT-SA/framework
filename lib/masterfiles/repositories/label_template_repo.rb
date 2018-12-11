# frozen_string_literal: true

module MasterfilesApp
  class LabelTemplateRepo < BaseRepo
    build_for_select :label_templates,
                     label: :label_template_name,
                     value: :id,
                     order_by: :label_template_name
    build_inactive_select :label_templates,
                          label: :label_template_name,
                          value: :id,
                          order_by: :label_template_name

    crud_calls_for :label_templates, name: :label_template, wrapper: LabelTemplate
  end
end
