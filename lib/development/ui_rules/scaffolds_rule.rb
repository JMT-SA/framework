# frozen_string_literal: true

module UiRules
  class ScaffoldsRule < Base
    def generate_rules
      @repo = DevelopmentApp::DevelopmentRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      add_behaviours

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
        shared_repo_name: { hint: 'Name of an existing or new repo to use to store persistence methods for more than one table.<p>The code will refer to this repo instead of using a name derived from the table.<br> Use CamelCase - <em>"MostAwesome"</em> for <em>"MostAwesomeRepo"</em>.</p>' },
        shared_factory_name: { hint: 'Name of an existing or new test factory to use to store factory definition methods for more than one table.<p>The code will be generated to be part of this factory instead of using a name derived from the table.<br> Use CamelCase - <em>"MostAwesome"</em> for <em>"MostAwesomeFactory"</em>.</p><p>This is a good idea for tables that are closely related like <em>widget_types</em> and <em>widgets</em>' },
        nested_route_parent: { renderer: :select, options: @repo.table_list, prompt: true },
        new_from_menu: { renderer: :checkbox, caption: 'Menu item for new resource',
                         hint: '<p>Set this if you want to call the new route from a menu item <br>(instead of or as well as from a button)</p>' },
        jobs: { hint: 'Names of jobs to be created (separated by commas). Names can be snake_case or CamelCase.' },
        services: { hint: 'Names of services to be created (separated by commas). Names can be snake_case or CamelCase.' }
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
                                    shared_repo_name: nil,
                                    shared_factory_name: nil,
                                    nested_route_parent: nil,
                                    new_from_menu: false)
    end

    private

    def add_behaviours
      behaviours do |behaviour|
        behaviour.enable :other, when: :applet, changes_to: ['other']
        behaviour.dropdown_change :table, notify: [{ url: '/development/generators/scaffolds/table_changed' }]
      end
    end

    def disable_other
      fields[:other][:disabled] = true unless form_object.applet == 'other'
    end

    def applets_list
      hold_dir = Dir.pwd
      dir = File.expand_path('../../applets', __dir__)
      Dir.chdir(dir)
      Dir.glob('*_applet.rb').map { |d| d.chomp('_applet.rb') }.push('other')
    ensure
      Dir.chdir(hold_dir)
    end
  end
end
