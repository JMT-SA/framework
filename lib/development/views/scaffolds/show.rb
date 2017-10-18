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
                section.add_text(results[:paths][:applet])
                section.add_text(results[:applet], preformatted: true, syntax: :ruby)
              end
            end
            page.section do |section|
              section.caption = 'Repo'
              section.hide_caption = false
              section.add_text(results[:paths][:repo])
              section.add_text(results[:repo], preformatted: true, syntax: :ruby)
            end
            page.section do |section|
              section.caption = 'Entity'
              section.hide_caption = false
              section.add_text(results[:paths][:entity])
              section.add_text(results[:entity], syntax: :ruby)
            end
            page.section do |section|
              section.caption = 'Routes'
              section.hide_caption = false
              section.add_text(results[:paths][:route])
              section.add_text(results[:route], syntax: :ruby)
            end
            page.section do |section|
              section.caption = 'Views'
              section.hide_caption = false
              section.add_text(results[:paths][:view][:new])
              section.add_text(results[:view][:new], syntax: :ruby)
              section.add_text(results[:paths][:view][:edit])
              section.add_text(results[:view][:edit], syntax: :ruby)
              section.add_text(results[:paths][:view][:show])
              section.add_text(results[:view][:show], syntax: :ruby)
            end
            page.section do |section|
              section.caption = 'Validation'
              section.hide_caption = false
              section.add_text(results[:paths][:validation])
              section.add_text(results[:validation], syntax: :ruby)
            end
            page.section do |section|
              section.caption = 'UI Rules'
              section.hide_caption = false
              section.add_text(results[:paths][:uirule])
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
              section.add_text(results[:paths][:dm_query])
              section.add_text(results[:dm_query], syntax: :yaml)
            end
            page.section do |section|
              section.caption = 'List YAML'
              section.hide_caption = false
              section.add_text(results[:paths][:list])
              section.add_text(results[:list], syntax: :yaml)
            end
            page.section do |section|
              section.caption = 'Search YAML'
              section.hide_caption = false
              section.add_text(results[:paths][:search])
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
      end
    end
  end
end
