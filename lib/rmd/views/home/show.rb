module Rmd
  module Home
    class Show
      def self.call(menu_items)
        rules = {}

        layout = Crossbeams::Layout::Page.build(rules) do |page|
          page.add_text '<h1>RMD menu</h1>'
          # Should exclude the home menu...
          menu_items[:programs].each do |_, prog|
            prog.each do |prg|
              page.add_text %(<h2 class="ma0">#{prg[:name]}</h2>)
              menu_items[:program_functions][prg[:id]].each do |pf|
                page.add_text %(<a href="#{pf[:url]}" class="f6 link dim br2 ph3 pv2 dib white bg-green mt2 w5 mw6">#{pf[:name]}</a>)
              end
            end
          end
        end

        layout
      end
    end
  end
end
