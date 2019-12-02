# frozen_string_literal: true

module PackMaterial
  module Dispatch
    module MrGoodsReturnedNote
      class Edit
        def self.call(id, user, form_values: nil, form_errors: nil, interactor: nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:mr_goods_returned_note, :edit, id: id, form_values: form_values, current_user: user, interactor: interactor)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page| # rubocop:disable Metrics/BlockLength
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors

            page.section do |section|
              section.add_control(control_type: :link,
                                  text: 'Back to GRNs',
                                  url: "/list/mr_goods_returned_notes/with_params?key=#{rules[:shipped] ? 'shipped' : 'unshipped'}",
                                  style: :back_button)
              section.add_control(control_type: :link,
                                  text: 'Ship Goods',
                                  url: "/pack_material/dispatch/mr_goods_returned_notes/#{id}/ship_goods",
                                  prompt: true,
                                  id: 'mr_goods_returned_notes_ship_button',
                                  visible: rules[:can_ship],
                                  style: :button)
              section.add_control(control_type: :link,
                                  text: 'Complete Purchase Invoice',
                                  url: "/pack_material/dispatch/mr_goods_returned_notes/#{id}/complete_invoice",
                                  prompt: true,
                                  id: 'mr_goods_returned_notes_complete_button',
                                  visible: rules[:can_complete_invoice],
                                  style: :button)
            end

            page.section do |section|
              section.form do |form|
                form.caption 'Edit Goods Returned Note'
                form.action "/pack_material/dispatch/mr_goods_returned_notes/#{id}"
                form.method :update
                form.row do |row|
                  row.column do |column|
                    column.add_field :credit_note_number
                    column.add_field :mr_delivery_id
                    column.add_field :issue_transaction_id
                    column.add_field :delivery_number
                    column.add_field :created_by
                    column.add_field :dispatch_location_id
                  end

                  row.column do |column|
                    column.add_field :remarks
                  end
                end
              end
            end

            page.section do |section|
              section.add_control(control_type: :link,
                                  text: 'Print Credit Note',
                                  url: "/pack_material/reports/print_credit_note/#{id}",
                                  loading_window: true,
                                  visible: rules[:shipped],
                                  style: :button)
              section.add_control(control_type: :link,
                                  text: "#{Crossbeams::Layout::Icon.render(:envelope)} Email Credit Note",
                                  url: "/pack_material/reports/email_credit_note/#{id}",
                                  behaviour: :popup,
                                  visible: rules[:shipped],
                                  style: :button)
            end

            page.section do |section|
              section.show_border!
              if rules[:shipped]
                section.add_grid('grn_items',
                                 "/list/mr_goods_returned_note_items_show/grid?key=standard&mr_goods_returned_note_id=#{id}",
                                 height: 16,
                                 caption: 'Goods Returned Items')
              else
                # Only if there are still options
                section.add_control(control_type: :link,
                                    text: 'New Item',
                                    url: "/pack_material/dispatch/mr_goods_returned_notes/#{id}/mr_goods_returned_note_items/new",
                                    style: :button,
                                    behaviour: :popup,
                                    grid_id: 'grn_items',
                                    css_class: 'mb1')
                section.add_grid('grn_items',
                                 "/list/mr_goods_returned_note_items/grid?key=standard&mr_goods_returned_note_id=#{id}",
                                 height: 16,
                                 caption: 'Goods Returned Items')
              end
            end
          end

          layout
        end
      end
    end
  end
end
