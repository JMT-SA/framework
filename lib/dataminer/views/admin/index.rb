# frozen_string_literal: true

module DM
  module Admin
    class Index
      def self.call(context = {}) # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity
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
        button_caption = if context[:for_grid_queries]
                           'Create a new grid query'
                         else
                           'Create a new report'
                         end
        new_url = '/dataminer/admin/new/'

        layout = Crossbeams::Layout::Page.build({}) do |page| # rubocop:disable Metrics/BlockLength
          page.section do |section|
            section.add_control(control_type: :link, text: button_caption, url: new_url, style: :button)
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
            section.fit_height!
            section.add_grid('rpt_grid', grid_url, caption: caption)
          end
        end

        layout
      end
    end
  end
end
