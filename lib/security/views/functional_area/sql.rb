module Security
  module FunctionalAreas
    module FunctionalArea
      class Sql
        def self.call(sql)
          layout = Crossbeams::Layout::Page.build({}) do |page|
            page.add_text sql, syntax: :sql
          end

          layout
        end
      end
    end
  end
end
