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
      klass    = UiRules.const_get(rule.to_s.split("_").map(&:capitalize).join)
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

    def set_common_fields(value)
      @rules[:fields] = value
    end

    def fields
      @rules[:fields]
    end

    def form_name(name)
      @rules[:name] = name
    end
  end
end
