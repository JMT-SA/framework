# frozen_string_literal: true

module Development
  module Generators
    module ScriptScaffolds
      class Show
        def self.call(results)
          ui_rule = UiRules::Compiler.new(:script_scaffold, :new)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.section do |section|
              section.caption = 'Script'
              section.hide_caption = false
              save_snippet_form(section, results[:path], results[:code])
              section.add_text(results[:code], preformatted: true, syntax: :ruby)
            end
          end

          layout
        end

        def self.save_snippet_form(section, path, code) # rubocop:disable Metrics/AbcSize
          if !File.exist?(File.join(ENV['ROOT'], path))
            section.form do |form|
              form.form_config = {
                name: 'snippet',
                fields: {
                  path: { readonly: true },
                  value: { renderer: :hidden }
                }
              }
              form.form_object OpenStruct.new(path: path, value: Base64.encode64(code))
              form.action '/development/generators/scaffolds/save_snippet'
              form.method :update
              form.remote!
              form.add_field :path
              form.add_field :value
              form.submit_captions 'Save', 'Saving'
            end
          else
            section.add_text(path)
          end
        end

        private_class_method :save_snippet_form
      end
    end
  end
end
