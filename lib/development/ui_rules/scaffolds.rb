module UiRules
  class Scaffolds < Base
    def generate_rules
      @this_repo = DevelopmentRepo.new
      make_form_object

      common_values_for_fields common_fields

      add_behaviour

      disable_other

      form_name 'scaffold'.freeze
    end

    def common_fields
      {
        table: { renderer: :select, options: @this_repo.table_list, prompt: true },
        applet: { renderer: :select, options: applets_list },
        other: {},
        program: {},
        label_field: {}
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @this_repo.find(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(table: nil, # could default to last table in last migration file?
                                    applet: nil,
                                    other: nil,
                                    program: nil,
                                    label_field: nil)
    end

    private

    def add_behaviour
      behaviours do |behaviour|
        behaviour.enable :other, when: :applet, changes_to: ['other']
      end
    end

    def disable_other
      fields[:other][:disabled] = true if [nil, 'other'].include?(form_object.applet)
    end

    def applets_list
      dir = File.expand_path('../../../applets', __FILE__)
      Dir.chdir(dir)
      Dir.glob('*_applet.rb').map { |d| d.sub(/_applet.rb$/, '') }.push('other')
    end
  end
end
