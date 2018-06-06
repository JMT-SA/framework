# frozen_string_literal: true

module DM
  module Admin
    class Index
      def self.call(context = {})
        grid_url = if context[:for_grid_queries]
                     '/dataminer/admin/grids_grid/'
                   else
                     '/dataminer/admin/reports_grid/'
                   end
        caption = if context[:for_grid_queries]
                    'Grid query listing'
                  else
                    'Report listing'
                  end
        new_url = '/dataminer/admin/new/'

        layout = Crossbeams::Layout::Page.build({}) do |page|
          page.section do |section|
            section.add_control(control_type: :link, text: 'Create a new report', url: new_url, style: :button)
          end

          unless context[:for_grid_queries]
            page.section do |section|
              section.add_text 'Convert an old-style YAML report'
              section.form do |form|
                form.form_config = {
                  name: 'convert',
                  fields: {
                    file: { subtype: :file, accept: '.yml', caption: 'Old YAML file' }
                  }
                }
                form.form_object OpenStruct.new(file: nil)
                form.inline!
                form.action '/dataminer/admin/convert/'
                form.multipart!
                form.add_field :file
                form.submit_captions 'Convert', 'Converting'
              end
            end
          end

          page.section do |section|
            section.add_grid('rpt_grid', grid_url, caption: caption)
          end
        end

        layout
      end
    end
  end
end
