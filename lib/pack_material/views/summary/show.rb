# frozen_string_literal: true

module PackMaterial
  module Summary
    class Show
      def self.call
        summary = PackMaterialApp::PmProductRepo.new.summary

        layout = Crossbeams::Layout::Page.build({}) do |page|
          page.row do |row|
            row.column do |col|
              col.add_text ENV['APP_CAPTION'], wrapper: :h2
              col.add_table summary, %i[item quantity], alignment: { quantity: :right }
            end
          end
        end

        layout
      end
    end
  end
end
