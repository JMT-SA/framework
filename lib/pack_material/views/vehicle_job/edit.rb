# frozen_string_literal: true

module PackMaterial
  module Tripsheets
    module VehicleJob
      class Edit
        def self.call(id, interactor, form_values: nil, form_errors: nil) # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
          ui_rule = UiRules::Compiler.new(:vehicle_job, :edit, id: id, interactor: interactor, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page| # rubocop:disable Metrics/BlockLength
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors

            page.section do |section|
              section.add_control(control_type: :link,
                                  text: 'Back to Tripsheets',
                                  url: "/list/vehicle_jobs/with_params?key=#{rules[:completed] ? 'completed' : 'incomplete'}", # Add complete toggle
                                  style: :back_button)
              section.add_control(control_type: :link,
                                  text: 'Mark as Loaded',
                                  url: "/pack_material/tripsheets/vehicle_jobs/#{id}/mark_as_loaded",
                                  prompt: true,
                                  visible: rules[:can_load],
                                  id: 'vehicle_job_mark_as_loaded',
                                  style: :button)
              section.add_control(control_type: :link,
                                  text: 'Confirm Arrival',
                                  url: "/pack_material/tripsheets/vehicle_jobs/#{id}/confirm_arrival",
                                  prompt: 'I hereby confirm that the vehicle has arrived in my warehouse. The stock is now in the receiving bay ready to be put away.',
                                  visible: rules[:can_confirm_arrival],
                                  id: 'vehicle_job_confirm_arrival',
                                  style: :button)
            end

            page.add_notice 'Please confirm arrival', notice_type: :info if rules[:can_confirm_arrival]

            cannot_edit = rules[:cannot_edit]
            page.section do |section|
              section.show_border!
              section.add_caption 'Tripsheet'
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
                    col.add_field :virtual_location_id
                    col.add_field :when_loaded
                    col.add_field :when_offloaded
                    col.add_field :arrival_confirmed
                    col.add_field :loaded
                    col.add_field :offloaded
                  end
                end
              end
            end

            page.section do |section|
              section.add_control(control_type: :link,
                                  text: 'Print Tripsheet',
                                  url: "/pack_material/reports/tripsheet/#{id}",
                                  loading_window: true,
                                  style: :button)
            end

            page.section do |section| #- rubocop:disable Metrics/BlockLength
              section.show_border!
              if rules[:loaded]
                section.add_grid('job_units',
                                 "/list/vehicle_job_units_show/grid?key=standard&vehicle_job_id=#{id}",
                                 height: 16,
                                 caption: 'Tripsheet Items')
              else
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
                                 caption: 'Tripsheet Items')
              end
            end
          end

          layout
        end
      end
    end
  end
end
