module UiRules
  class BlockAuth
    def authorized?
      raise 'Cannot check authorization - no authorizer supplied to UiRules::Compiler.'
    end
  end

  class Compiler
    def initialize(rule, mode, options = {})
      @options = options
      authorizer = options.delete(:authorizer) || BlockAuth.new
      klass    = UiRules.const_get("#{rule.to_s.split('_').map(&:capitalize).join}Rule")
      @rule    = klass.new(mode, authorizer, options)
    end

    def compile
      @rule.generate_rules
      @rule.rules
    end

    def form_object
      @rule.form_object
    end
  end

  class Base
    attr_reader :rules
    def initialize(mode, authorizer, options)
      @mode        = mode
      @authorizer  = authorizer
      @options     = options
      @form_object = nil
      @rules       = {}
    end

    def form_object
      @form_object || raise("#{self.class} did not implement the form object")
    end

    private

    def common_values_for_fields(value)
      @rules[:fields] = value
    end

    def fields
      @rules[:fields]
    end

    def form_name(name)
      @rules[:name] = name
    end

    def behaviours
      behaviour = Behaviour.new
      yield behaviour
      @rules[:behaviours] = behaviour.rules
    end

    def apply_form_values
      return unless @options && @options[:form_values]
      # We need to apply values to the form object, so make sure it is not immutable first.
      @form_object = OpenStruct.new(@form_object.to_h)

      @options[:form_values].each do |k, v|
        @form_object.public_send("#{k}=", v)
      end
    end
  end

  class Behaviour
    attr_reader :rules
    def initialize
      @rules = []
    end

    def enable(field_to_enable, conditions = {})
      observer = conditions[:when] || raise(ArgumentError, 'Enable behaviour requires `when`.')
      change_values = conditions[:changes_to]
      @rules << { observer => { change_affects: field_to_enable } }
      @rules << { field_to_enable => { enable_on_change: change_values } }
    end

    def dropdown_change(field_name, conditions = {})
      raise(ArgumentError, 'Dropdown change behaviour requires `notify: url`.') if conditions[:notify].any? { |c| c[:url].nil? }
      @rules << { field_name => {
        notify: conditions[:notify].map do |n|
          {
            url: n[:url],
            param_keys: n[:param_keys] || [],
            param_values: n[:param_values] || {}
          }
        end
      } }
    end
  end
end
