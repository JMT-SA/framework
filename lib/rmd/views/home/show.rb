module Rmd
  module Home
    class Show
      def self.call(menu_items) # rubocop:disable Metrics/AbcSize
        rules = {}

        layout = Crossbeams::Layout::Page.build(rules) do |page|
          page.add_text '<h1>RMD menu</h1>'
          # Should exclude the home menu...
          menu_items[:programs].each do |_, prog|
            prog.each do |prg|
              page.add_text %(<h2 class="ma0">#{prg[:name]}</h2>)
              combin = menu_items[:program_functions][prg[:id]].map { |r| [r[:group_name], r[:url], r[:name]] }
              grp = nil
              combin.each do |group, url, name|
                if group != grp
                  page.add_text %(<h3 class="gray ml3 mb0 mt1">#{group}</h3>) unless group.nil?
                  grp = group
                end
                group_indent = group.nil? ? '' : ' ml4'
                page.add_text %(<a href="#{url}" class="f6 link dim br2 ph3 pv2 dib white bg-green mt2 w5 mw6#{group_indent}">#{name}</a>)
              end
            end
          end
        end

        layout
      end
    end
  end
end
