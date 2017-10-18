# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/BlockLength

module Development
  module Generators
    module Scaffolds
      class Show
        def self.call(results)
          ui_rule = UiRules::Compiler.new(:scaffolds, :new)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.section do |section|
              section.add_text <<~EOS
                <p>
                  Preview of files to be generated.<br>
                  <em>Note the permissions required for program <strong>#{results[:opts].program}</strong></em>
                </p>
              EOS
            end
            if results[:applet]
              page.section do |section|
                section.caption = 'Applet'
                section.hide_caption = false
                save_snippet_form(section, results[:paths][:applet], results[:applet])
                section.add_text(results[:applet], preformatted: true, syntax: :ruby)
              end
            end
            page.section do |section|
              section.caption = 'Repo'
              section.hide_caption = false
              save_snippet_form(section, results[:paths][:repo], results[:repo])
              section.add_text(results[:repo], preformatted: true, syntax: :ruby)
            end
            page.section do |section|
              section.caption = 'Entity'
              section.hide_caption = false
              save_snippet_form(section, results[:paths][:entity], results[:entity])
              section.add_text(results[:entity], syntax: :ruby)
            end
            page.section do |section|
              section.caption = 'Routes'
              section.hide_caption = false
              save_snippet_form(section, results[:paths][:route], results[:route])
              section.add_text(results[:route], syntax: :ruby)
            end
            page.section do |section|
              section.caption = 'Views'
              section.hide_caption = false
              save_snippet_form(section, results[:paths][:view][:new], results[:view][:new])
              section.add_text(results[:view][:new], syntax: :ruby)
              save_snippet_form(section, results[:paths][:view][:edit], results[:view][:edit])
              section.add_text(results[:view][:edit], syntax: :ruby)
              save_snippet_form(section, results[:paths][:view][:show], results[:view][:show])
              section.add_text(results[:view][:show], syntax: :ruby)
            end
            page.section do |section|
              section.caption = 'Validation'
              section.hide_caption = false
              save_snippet_form(section, results[:paths][:validation], results[:validation])
              section.add_text(results[:validation], syntax: :ruby)
            end
            page.section do |section|
              section.caption = 'UI Rules'
              section.hide_caption = false
              save_snippet_form(section, results[:paths][:uirule], results[:uirule])
              section.add_text(results[:uirule], syntax: :ruby)
            end
            page.section do |section|
              section.caption = 'Query to use in Dataminer'
              section.hide_caption = false
              section.add_text(<<~EOS)
                <p>
                  The query might need tweaking - especially if there are joins.
                  Adjust it and edit the Dataminer Query.
                </p>
              EOS
              section.add_text(results[:query], syntax: :sql)
            end
            page.section do |section|
              section.caption = 'Dataminer Query YAML'
              section.hide_caption = false
              save_snippet_form(section, results[:paths][:dm_query], results[:dm_query])
              section.add_text(results[:dm_query], syntax: :yaml)
            end
            page.section do |section|
              section.caption = 'List YAML'
              section.hide_caption = false
              save_snippet_form(section, results[:paths][:list], results[:list])
              section.add_text(results[:list], syntax: :yaml)
            end
            page.section do |section|
              section.caption = 'Search YAML'
              section.hide_caption = false
              save_snippet_form(section, results[:paths][:search], results[:search])
              section.add_text(results[:search], syntax: :yaml)
            end
            page.section do |section|
              section.caption = 'Optional SQL for inserting menu items'
              section.hide_caption = false
              section.add_text(results[:menu], syntax: :sql)
            end
          end

          layout
        end

        private

        def self.save_snippet_form(section, path, code)
          if !File.exists?(File.join(ENV['ROOT'], path))
            section.form do |form|
              form.form_config = { name: 'snippet', fields: { path: { readonly: true },
                                                            value: { renderer: :hidden } } }
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
      end
    end
  end
end
