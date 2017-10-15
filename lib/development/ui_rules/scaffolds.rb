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
      # DSL on Base that transfers this into something on rules like:
      # behaviours: [ { applet: { change_affects: :other } },
      #               { other:  { enable_on_change: ['other'] } } ]
      # behaviours do
      #   enable :other, when: :applet, changes_to: ['other']
      # end
      #
      # THEN in layout,
      # applet gets data-change-values="scaffold_other" (this could be ="field1,field2") << points to field id
      # other  gets data-enable-on-values="other" (could also be a list of values)      << has value(s) on which to disable
      #
      #
      # THEN in JS,
      # Listen to change of combo with datalist changeValues
      # - go through list of ids and get element.
      # - if element has datalist enableOnValues, check if target value is in the list.
      # - if in list, enable, else disable
    end

    def disable_other
      fields[:other][:disabled] = true if form_object.applet && form_object.applet != 'other'
    end

    def applets_list
      dir = File.expand_path('../../../applets', __FILE__)
      Dir.chdir(dir)
      Dir.glob('*_applet.rb').map { |d| d.sub(/_applet.rb$/, '') }.unshift('other')
    end
  end
end
