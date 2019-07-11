# frozen_string_literal: true

module Development
  module Documentation
    class LayoutIcons
      def self.call # rubocop:disable Metrics/AbcSize
        body = Crossbeams::Layout::Icon.available_icons.map { |i| "<li class='pa2'>#{Crossbeams::Layout::Icon.render(i, css_class: 'mr1')} Crossbeams::Layout::Icon.render(<strong>:#{i}</strong>)</li>" }.join

        layout = Crossbeams::Layout::Page.build({}) do |page|
          page.section do |section|
            section.add_text 'Layout icons', wrapper: :h1
            section.add_control(control_type: :link, text: 'Back to documentation home', url: '/developer_documentation/start.adoc', style: :back_button)
            section.add_control(control_type: :link, text: 'Back to icon documentation', url: '/developer_documentation/icons.adoc', style: :back_button)
            section.add_control(control_type: :link, text: 'Grid icon list', url: '/development/grid_icons', style: :button)
            section.add_control(control_type: :link, text: 'Grid column icon list', url: '/development/grid_column_icons', style: :button)
            section.add_text <<~HTML, wrapper: :p
              These are the icons that are available to use in views.<br>
              To render an icon, call Crossbeams::Layout::Icon.render with a symbol matching one of the available icons listed below.
            HTML
            section.add_text %(Crossbeams::Layout::Icon.render(:icon_name, css_class: 'mr1 pa1', attrs: ['id="icon1", 'data-click="true"'])), syntax: :ruby
            section.add_text <<~HTML
              The render method accepts options which can be any combination of <em>:css_class</em> or <em>:attrs</em> (or neither).<br>
              e.g. to change the colour of an icon, include a css class that implements the colour property.
            HTML
            section.add_text <<~HTML
              <ul class="list pl0">
              #{body}
              </ul>
            HTML
          end
        end

        layout
      end
    end
  end
end
