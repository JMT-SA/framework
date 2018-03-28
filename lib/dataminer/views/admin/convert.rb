# frozen_string_literal: true

module DM
  module Admin
    class Convert
      def self.call(tempfile, filename)
        ui_rule = UiRules::Compiler.new(:convert_report, :convert, tempfile: tempfile, filename: filename)
        rules   = ui_rule.compile

        layout = Crossbeams::Layout::Page.build(rules) do |page|
          page.form_object ui_rule.form_object
          page.form do |form|
            form.action '/dataminer/admin/save_conversion/'
            form.add_field :database
            form.add_field :filename
            form.add_field :temp_path
            form.add_field :yml
            form.add_field :sql
            form.add_text(notes, wrapper: :p)
          end
        end

        layout
      end

      def self.notes
        <<~HTML
          <strong>NB</strong> remove all <em>column={column}</em> parts of the WHERE clause before converting.<br>
          Also remove any SUBQSTART and SUBQEND references.
          <br>This code tries to do as much as possible, but you need to check the where clause - especially for stray "and"s.
        HTML
      end
    end
  end
end
