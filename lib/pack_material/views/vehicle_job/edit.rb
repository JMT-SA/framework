# frozen_string_literal: true

module PackMaterial
  module Tripsheets
    module VehicleJob
      class Edit
        def self.call(id, interactor, form_values: nil, form_errors: nil)
          ui_rule = UiRules::Compiler.new(:vehicle_job, :edit, id: id, form_values: form_values)
          rules   = ui_rule.compile

          cannot_edit = rules[:cannot_edit]

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors

            page.section do |section| # rubocop:disable Metrics/BlockLength
              section.add_control(control_type: :link,
                                  text: 'Back to Vehicle Jobs',
                                  url: "/list/vehicle_jobs/with_params?key=#{rules[:completed] ? 'completed' : 'incomplete'}", # Add complete toggle
                                  style: :back_button)
              section.add_control(control_type: :link,
                                  text: 'Fully Loaded',
                                  url: "/pack_material/replenish/mr_deliveries/#{id}/fully_loaded",
                                  prompt: true,
                                  style: :button)
              section.add_control(control_type: :link,
                                  text: 'Confirm Arrival',
                                  url: "/pack_material/replenish/mr_deliveries/#{id}/confirm_arrival",
                                  prompt: 'I hereby confirm that the vehicle has arrived in my warehouse. The stock is now in the receiving bay ready to be put away.',
                                  visible: rules[:can_arrive],
                                  style: :button)
            end

            page.add_notice 'Please confirm arrival', notice_type: :info if rules[:can_arrive]

            page.section do |section|
              section.show_border!
              section.add_caption 'Vehicle Job'
              section.form do |form|
                form.action "/pack_material/tripsheets/vehicle_jobs/#{id}"
                form.method :update unless cannot_edit
                form.view_only! if cannot_edit
                form.no_submit! if cannot_edit
                form.row do |row|
                  row.column do |col|
                    col.add_field :tripsheet_number
                    col.add_field :business_process_id
                    col.add_field :vehicle_id
                    col.add_field :departure_location_id
                  end

                  row.column do |col|
                    col.add_field :planned_location_id
                    col.add_field :when_loaded
                    col.add_field :when_offloaded
                  end
                end
              end
            end

            page.section do |section|
              section.add_control(control_type: :link,
                                  text: 'Print Tripsheet',
                                  url: "/pack_material/reports/tripsheet/#{id}",
                                  loading_window: true,
                                  # visible: rules[:is_fully_loaded],
                                  style: :button)
            end

            page.section do |section| # rubocop:disable Metrics/BlockLength
              section.show_border!
              unless cannot_edit
                section.add_control(control_type: :link,
                                    text: 'New Unit',
                                    url: "/pack_material/tripsheets/vehicle_jobs/#{id}/vehicle_job_units/new",
                                    style: :button,
                                    behaviour: :popup,
                                    grid_id: 'job_units',
                                    css_class: 'mb1')
                section.add_grid('job_units',
                                 "/list/vehicle_job_units/grid?key=standard&vehicle_job_id=#{id}",
                                 height: 16,
                                 caption: 'Vehicle Job Units')
              end
              if (rules[:can_add_invoice] || rules[:can_complete_invoice]) && !rules[:invoice_completed] || rules[:over_supply_accepted]
                section.add_grid('job_units',
                                 "/list/vehicle_job_units_edit_unit_prices/grid?key=standard&vehicle_job_id=#{id}",
                                 height: 16,
                                 caption: 'Vehicle Job Units')
              end
              if rules[:completed]
                section.add_grid('job_units',
                                 "/list/vehicle_job_units_show/grid?key=standard&vehicle_job_id=#{id}",
                                 height: 16,
                                 caption: 'Vehicle Job Units')
              end
            end
          end

          layout
        end
      end
    end
  end
end
