# frozen_string_literal: true

module UiRules
  class ScaffoldsRule < Base
    def generate_rules
      @repo = DevelopmentApp::DevelopmentRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      add_behaviour

      disable_other

      form_name 'scaffold'
    end

    def common_fields
      {
        table: { renderer: :select, options: @repo.table_list, prompt: true, required: true },
        applet: { renderer: :select, options: applets_list },
        other: { force_lowercase: true, caption: 'New applet (Other)' },
        program: { required: true, force_lowercase: true },
        label_field: {},
        short_name: { required: true, caption: 'Short name based on table name' },
        shared_repo_name: { hint: 'Name of an existing or new repo to use to store persistence methods for more than one table.<p>The code will refer to this repo instead of using a name derived from the table.<br> Use CamelCase - <em>"MostAwesome"</em> for <em>"MostAwesoneRepo"</em>.</p>' },
        nested_route_parent: { renderer: :select, options: @repo.table_list, prompt: true },
        new_from_menu: { renderer: :checkbox, caption: 'Menu item for new resource' }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(table: nil, # could default to last table in last migration file?
                                    applet: nil,
                                    other: nil,
                                    program: nil,
                                    label_field: nil,
                                    short_name: nil,
                                    short_repo_name: nil,
                                    nested_route_parent: nil,
                                    new_from_menu: false)
    end

    private

    def add_behaviour
      behaviours do |behaviour|
        behaviour.enable :other, when: :applet, changes_to: ['other']
        behaviour.dropdown_change :table, notify: [{ url: '/development/generators/scaffolds/table_changed' }]
      end
    end

    def disable_other
      fields[:other][:disabled] = true unless form_object.applet == 'other'
    end

    def applets_list
      dir = File.expand_path('../../applets', __dir__)
      Dir.chdir(dir)
      Dir.glob('*_applet.rb').map { |d| d.chomp('_applet.rb') }.push('other')
    end
  end
end
