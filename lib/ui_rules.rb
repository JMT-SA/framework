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

  class Base # rubocop:disable Metrics/ClassLength
    attr_reader :rules, :inflector
    def initialize(mode, authorizer, options)
      @mode        = mode
      @authorizer  = authorizer
      @options     = options
      @form_object = nil
      @inflector   = Dry::Inflector.new
      @rules       = { fields: {} }
    end

    def form_object
      @form_object || raise("#{self.class} did not implement the form object")
    end

    private

    def make_caption(value)
      inflector.humanize(value.to_s).gsub(/\s\D/, &:upcase)
    end

    def extended_columns(repo, table, edit_mode: true)
      config = Crossbeams::Config::ExtendedColumnDefinitions.config_for(table)
      return if config.nil?

      config.each do |key, defn|
        caption = make_caption(key)
        fields["extcol_#{key}".to_sym] = if edit_mode
                                           renderer_for_extcol(repo, defn, caption)
                                         else
                                           { renderer: :label, caption: caption, as_boolean: defn[:type] == :boolean }
                                         end
      end
    end

    # Generate HTML for a table of columns from the +@form_object+.
    def compact_header(columns:, display_columns: 2, header_captions: {}) # rubocop:disable Metrics/AbcSize
      raise("#{self.class} form object has not been set up before calling 'compact_header`") if @form_object.nil?

      row = 0
      cells = {}
      columns.each_with_index do |a, i|
        row += 1 if (i % display_columns).zero?
        cells[row] ||= []
        val = @form_object[a]
        val = <<~HTML if val.is_a?(TrueClass)
          <div class="cbl-input dark-green">
            #{Crossbeams::Layout::Icon.render(:checkon, css_class: 'mr1')}
          </div>
        HTML
        val = <<~HTML if val.is_a?(FalseClass)
          <div class="cbl-input light-red">
            #{Crossbeams::Layout::Icon.render(:checkoff, css_class: 'mr1')}
          </div>
        HTML
        cells[row] << %(<td class="b gray">#{header_captions[a] || make_caption(a)}</td><td>#{val}</td>)
      end

      inner = cells.map do |_, v|
        %(<tr class="hover-row">#{v.join}</tr>)
      end.join

      @rules[:compact_header] = <<~HTML
        <table class="thinbordertable">
          #{inner}
        </table>
      HTML
    end

    def render_icon(icon)
      return '' if icon.nil?

      icon_parts = icon.split(',')
      svg = File.read(File.join(ENV['ROOT'], 'public/app_icons', "#{icon_parts.first}.svg"))
      color = icon_parts[1] || 'gray'
      %(<div class="crossbeams-field"><label>Icon</label><div class="cbl-input"><span class="cbl-icon" style="color:#{color}">#{svg}</span></div></div>)
    end

    def renderer_for_extcol(repo, config, caption)
      field = { caption: caption }
      if config[:masterlist_key]
        field[:renderer] = :select
        field[:prompt] = true
        field[:options] = repo.master_list_values(config[:masterlist_key])
      elsif %i[integer number numeric].include?(config[:type])
        field[:renderer] = config[:type]
      elsif config[:type] == :boolean
        field[:renderer] = :checkbox
      end
      field[:required] = true if config[:required]
      field[:pattern] = config[:pattern] if config[:pattern]
      field
    end

    def apply_extended_column_defaults_to_form_object(table) # rubocop:disable Metrics/AbcSize
      config = Crossbeams::Config::ExtendedColumnDefinitions.config_for(table)
      return if config.nil?

      col_with_default = {}
      config.each do |key, defn|
        next if defn[:default].nil?

        col_with_default[key.to_s] = defn[:default]
      end
      return if col_with_default.empty?

      if @form_object.is_a?(Hash) || @form_object.is_a?(OpenStruct)
        @form_object[:extended_columns] = col_with_default
      else
        hs = @form_object.to_h
        hs[:extended_columns] = col_with_default
        @form_object = OpenStruct(hs)
      end
    end

    def common_values_for_fields(value = nil)
      @rules[:fields] = value.nil? ? {} : value
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
        @form_object[k] = v
      end
    end
  end

  class Behaviour
    attr_reader :rules
    def initialize
      @rules = []
    end

    def enable(field_to_enable, conditions = {})
      targets = Array(field_to_enable)
      observer = conditions[:when] || raise(ArgumentError, 'Enable behaviour requires `when`.')
      change_values = conditions[:changes_to]
      @rules << { observer => { change_affects: targets.join(';') } }
      targets.each do |target|
        @rules << { target => { enable_on_change: change_values } }
      end
    end

    def dropdown_change(field_name, conditions = {})
      raise(ArgumentError, 'Dropdown change behaviour requires `notify: url`.') if (conditions[:notify] || []).any? { |c| c[:url].nil? }

      @rules << { field_name => {
        notify: (conditions[:notify] || []).map do |n|
          {
            url: n[:url],
            param_keys: n[:param_keys] || [],
            param_values: n[:param_values] || {}
          }
        end
      } }
    end

    def populate_from_selected(field_name, conditions = {})
      @rules << { field_name => {
        populate_from_selected: (conditions[:populate_from_selected] || []).map do |p|
          {
            sortable: p[:sortable]
          }
        end
      } }
    end

    def keyup(field_name, conditions = {})
      raise(ArgumentError, 'Key up behaviour requires `notify: url`.') if (conditions[:notify] || []).any? { |c| c[:url].nil? }

      @rules << { field_name => {
        keyup: (conditions[:notify] || []).map do |n|
          {
            url: n[:url],
            param_keys: n[:param_keys] || [],
            param_values: n[:param_values] || {}
          }
        end
      } }
    end

    def lose_focus(field_name, conditions = {})
      raise(ArgumentError, 'Key up behaviour requires `notify: url`.') if (conditions[:notify] || []).any? { |c| c[:url].nil? }

      @rules << { field_name => {
        lose_focus: (conditions[:notify] || []).map do |n|
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
