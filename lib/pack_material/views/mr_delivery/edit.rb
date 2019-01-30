# frozen_string_literal: true

module PackMaterial
  module Replenish
    module MrDelivery
      class Edit
        def self.call(id, form_values: nil, form_errors: nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:mr_delivery, :edit, id: id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors

            page.section do |section|
              section.add_control(control_type: :link,
                                  text: 'Back to Deliveries',
                                  url: '/list/mr_deliveries',
                                  style: :back_button)
              if rules[:can_verify] && !rules[:show_only]
                section.add_control(control_type: :link,
                                    text: 'Verify Delivery',
                                    url: "/pack_material/replenish/mr_deliveries/#{id}/verify",
                                    prompt: true,
                                    style: :button)
              end
            end

            page.section do |section|
              section.show_border!
              section.form do |form|
                form.action "/pack_material/replenish/mr_deliveries/#{id}"
                form.method :update unless rules[:show_only]
                form.view_only! if rules[:show_only]
                form.no_submit!
                form.row do |row|
                  row.column do |col|
                    col.add_field :delivery_number
                    col.add_field :transporter
                    col.add_field :status
                    col.add_field :transporter_party_role_id
                    col.add_field :driver_name
                  end

                  row.column do |col|
                    col.add_field :client_delivery_ref_number
                    col.add_field :vehicle_registration
                    col.add_field :supplier_invoice_ref_number
                  end
                end
              end
            end

            page.section do |section|
              section.show_border!
              section.row do |row|
                row.column do |col|
                  if rules[:show_only]
                    col.add_grid('del_items',
                                 "/list/mr_delivery_items_show/grid?key=standard&delivery_id=#{id}",
                                 height: 8,
                                 caption: 'Delivery Line Items')
                  else
                    col.add_control(control_type: :link,
                                    text: 'New Item',
                                    url: "/pack_material/replenish/mr_deliveries/#{id}/mr_delivery_items/preselect",
                                    style: :button,
                                    behaviour: :popup,
                                    grid_id: 'del_items',
                                    css_class: 'mb1')
                    col.add_grid('del_items',
                                 "/list/mr_delivery_items/grid?key=standard&delivery_id=#{id}",
                                 height: 8,
                                 caption: 'Delivery Line Items')
                  end
                end
              end
            end
          end

          layout
        end
      end
    end
  end
end
