module Crossbeams
  # Form for RMD (Registered Mobile Devices)
  #
  # This renders a form that is simpler than the Crossbeams::Layout form
  # specifically for RMDs using the layout_rmd view.
  class RMDForm # rubocop:disable Metrics/ClassLength
    attr_reader :form_state, :form_name, :progress, :notes, :scan_with_camera,
                :caption, :action, :button_caption, :csrf_tag, :rules

    # Create a form.
    #
    # @param form_state [Hash] state of form (errors, current values)
    # @param options (Hash) options for the form
    # @option options [String] :form_name The name of the form.
    # @option options [String] :caption The caption for the form.
    # @option options [String] :progress Any progress to display (scanned 1 of 20 etc.)
    # @option options [String] :notes Any Notes to display on the form.
    # @option options [Boolean] :scan_with_camera Should the RMD be able to use the camera to scan. Default is false.
    # @option options [String] :action The URL for the POST action.
    # @option options [String] :button_caption The submit button's caption.
    # @option options [String] :button_id The submit button's DOM id.
    # @option options [Boolean] :button_initially_hidden Render the form with a hidden submit button.
    # @option options [Boolean] :no_submit Should the RMD form exclude a submit button? Default is false.
    # @option options [Boolean] :reset_button Should the RMD form include a button to reset form values? Default is true.
    # @option options [Array] :step_and_total The step number and total no of steps. Optional - only prints if the caption is given.
    # @option options [Array] :links An array of hashes with { :caption, :url, :prompt (optional) } which provide links to navigate away.
    def initialize(form_state, options) # rubocop:disable Metrics/AbcSize
      @form_state = form_state.to_h
      @form_name = options.fetch(:form_name)
      @progress = options[:progress]
      @notes = options[:notes]
      @scan_with_camera = options[:scan_with_camera] == true
      @caption = options[:caption]
      @step_number, @step_count = Array(options[:step_and_total])
      @links = options[:links] || []
      @no_submit = options.fetch(:no_submit, false)
      @action = @no_submit ? '/' : options.fetch(:action)
      @button_caption = options[:button_caption]
      @button_id = options[:button_id]
      @button_initially_hidden = options[:button_initially_hidden]
      @reset_button = options.fetch(:reset_button, true)
      @buttons = []
      @fields = []
      @rules = []
      @csrf_tag = nil
    end

    # Add a field to the form.
    # The field will render as an input with name = FORM_NAME[FIELD_NAME]
    # and id = FORM_NAME_FIELD_NAME.
    #
    # @param name [symbol] the name of the form field.
    # @param label [string] the caption for the label to appear beside the input.
    # @param options (Hash) options for the field
    # @option options [Boolean] :required Is the field required? Defaults to true.
    # @option options [Boolean] :hide_on_load should this element be hidden when the form loads?
    # @option options [String] :data_type the input type. Defaults to 'text'.
    # @option options [Integer] :width the input with in rem. Defaults to 12.
    # @option options [Boolean] :allow_decimals can a data_type="number" input accept decimals?
    # @option options [Boolean] :submit_form Should the form be submitted automatically after a scan result is placed in this field?
    # @option options [String] :scan The type of barcode symbology to accept. e.g. 'key248_all' for any symbology. Omit for input that does not receive a scan result.
    # Possible values are: key248_all (any symbology), key249_3o9 (309), key250_upc (UPC), key251_ean (EAN), key252_2d (2D - QR etc)
    # @option options [Symbol] :scan_type the type of barcode to expect in the field. This must have a matching entry in AppConst::BARCODE_PRINT_RULES.
    # @return [void]
    def add_field(name, label, options = {}) # rubocop:disable Metrics/AbcSize
      @current_field = name
      for_scan = options[:scan] ? 'Scan ' : ''
      data_type = options[:data_type] || 'text'
      width = options[:width] || 12
      required = options[:required].nil? || options[:required] ? ' required' : ''
      autofocus = autofocus_for_field(name)
      @fields << <<~HTML
        <tr id="#{form_name}_#{name}_row"#{field_error_state}#{initial_visibilty(options)}><th align="left">#{label}#{field_error_message}</th>
        <td><div class="rmdScanFieldGroup"><input class="pa2#{field_error_class}#{field_upper_class(options)}" id="#{form_name}_#{name}" type="#{data_type}"#{decimal_or_int(data_type, options)} name="#{form_name}[#{name}]" placeholder="#{for_scan}#{label}"#{scan_opts(options)} #{render_behaviours} style="width:#{width}rem;" value="#{field_value(form_state[name])}"#{required}#{autofocus}#{lookup_data(options)}#{submit_form(options)}#{set_readonly(form_state[name], for_scan)}#{attr_upper(options)}>#{clear_button(for_scan)}</div>#{hidden_scan_type(name, options)}#{lookup_display(name, options)}
        </td></tr>
      HTML
    end

    # Add a toggle (checkbox) field to the form.
    # The field will render as a toggle with name = FORM_NAME[FIELD_NAME]
    # and id = FORM_NAME_FIELD_NAME.
    # The value returned in params is 't' or 'f'.
    #
    # @param name [symbol] the name of the form field.
    # @param label [string] the caption for the label to appear beside the input.
    # @param options (Hash) options for the field
    # @option options [Boolean] :hide_on_load should this element be hidden when the form loads?
    # @return [void]
    def add_toggle(name, label, options = {}) # rubocop:disable Metrics/AbcSize
      @current_field = name
      @fields << <<~HTML
        <tr id="#{form_name}_#{name}_row"#{field_error_state}#{initial_visibilty(options)}><th align="left"><label for="#{form_name}_#{name}">#{label}</label>#{field_error_message}</th>
        <td>
            <input name="#{form_name}[#{name}]" type="hidden" value="f">
          <label class="switch">
            <input type="checkbox" class="pa2#{field_error_class} toggleCheck" id="#{form_name}_#{name}" name="#{form_name}[#{name}]" #{render_behaviours} value="t"#{checked(field_value(form_state[name]))}><span class="slider round"></span>
          </label>
        </td></tr>
      HTML
    end

    # TODO: Add disabled_items to select

    # Add a select box to the form.
    # The field will render as an input with name = FORM_NAME[FIELD_NAME]
    # and id = FORM_NAME_FIELD_NAME.
    #
    # @param name [symbol] the name of the form field.
    # @param label [string] the caption for the label to appear beside the select.
    # @param options (Hash) options for the field
    # @option options [Boolean] :required Is the field required? Defaults to true.
    # @option options [Boolean] :hide_on_load should this element be hidden when the form loads?
    # @option options [String] :value the selected value.
    # @option options [String,Boolean] :prompt if true, display a generic prompt. If a string, display the string as prompt.
    # @option options [Array,Hash] :items the select options.
    # @return [void]
    def add_select(name, label, options = {}) # rubocop:disable Metrics/AbcSize
      @current_field = name
      required = options[:required].nil? || options[:required] ? ' required' : ''
      items = options[:items] || []
      autofocus = autofocus_for_field(name)
      value = form_state[name] || options[:value]
      @fields << <<~HTML
        <tr id="#{form_name}_#{name}_row"#{field_error_state}#{initial_visibilty(options)}><th align="left">#{label}#{field_error_message}</th>
        <td><select class="pa2#{field_error_class}" id="#{form_name}_#{name}" name="#{form_name}[#{name}]" #{required}#{autofocus} #{render_behaviours}>
          #{make_prompt(options[:prompt])}#{build_options(items, value)}
        </select>
        </td></tr>
      HTML
    end

    # Add a label field (display-only) to the form.
    # The field will render as a grey box.
    # An optional accompanying hidden input can be rendered:
    #    with name = FORM_NAME[FIELD_NAME]
    #    and id = FORM_NAME_FIELD_NAME.
    #
    # @param name [symbol] the name of the form field.
    # @param label [string] the caption for the label to appear beside the input.
    # @param value [string] the value to be displayed in the label.
    # @param hidden_value [string] the value of the hidden field. If nil, no hidden field will be generated.
    # @param options (Hash) options for the field
    # @option options [Boolean] :hide_on_load should this element be hidden when the form loads?
    # @option options [String] :value_class a string of css class(es) to wrap around the label value.
    # @return [void]
    def add_label(name, label, value, hidden_value = nil, options = {}) # rubocop:disable Metrics/AbcSize
      tr_css_class = options[:as_table_cell] ? ' class="hover-row"' : ''
      td_css_class = options[:as_table_cell] ? ' class="rmd-table-cell"' : ''
      v_classes = [options[:value_class]]
      v_classes << 'pa2 bg-moon-gray br2' unless options[:as_table_cell]
      div_css_class = v_classes.compact.empty? ? '' : %( class="#{v_classes.compact.join(' ')}")
      @fields << <<~HTML
        <tr id="#{form_name}_#{name}_row"#{initial_visibilty(options)}#{tr_css_class}><th#{td_css_class} align="left">#{label}</th>
        <td#{td_css_class}><div#{div_css_class} id="#{form_name}_#{name}_value">#{field_value(value) || '&nbsp;'}</div>#{hidden_label(name, hidden_value)}
        </td></tr>
      HTML
    end

    # Render a section caption in bold that takes up the width of the table.
    #
    # @param caption [string] the caption for the section.
    # @param options (Hash) options for the header
    # @option options [String] :id the DOM id of the element
    # @option options [Boolean] :hide_on_load should this element be hidden when the form loads?
    # @return [void]
    def add_section_header(caption, options = {})
      raise ArgumentError, 'Section header caption cannot be blank' if caption.nil_or_empty?

      id = options[:id] || "sh_#{caption.hash}"
      @fields << <<~HTML
        <tr id="#{id}"#{initial_visibilty(options)}>
          <td colspan="2" class="b mid-gray">#{caption}</td>
        </tr>
      HTML
    end

    # Add a button to the form.
    # This button submits the same form, but to a different url (provided in action param)
    #
    # @param caption [string] the caption for the button.
    # @param action [string] the url target for the form.
    # @param options (Hash) options for the header
    # @option options [String] :id the DOM id of the element
    # @option options [Boolean] :hide_on_load should this element be hidden when the form loads?
    # @return [void]
    def add_button(caption, action, options = {})
      raise ArgumentError, 'Button caption cannot be blank' if caption.nil_or_empty?
      raise ArgumentError, 'Button action cannot be blank' if action.nil_or_empty?

      id = options[:id] || "btn_#{caption.hash}"
      @buttons << <<~HTML
        <button id="#{id}" formaction="#{action}" type="submit" data-disable-with="Processing..." class="dim br2 pa3 bn white bg-gray mr3" data-rmd-btn="Y"#{initial_visibilty(options)} />
          #{caption}
        </button>
      HTML
    end

    # Render the form.
    #
    # @return [String] HTML for the form.
    def render
      raise ArgumentError, 'RMDForm: no CSRF tag provided' if csrf_tag.nil?

      <<~HTML
        <h2>#{caption}#{page_number_and_page_count}</h2>
        <form action="#{action}" method="POST">
          #{error_section}
          #{notes_section}
          #{camera_section}
          #{csrf_tag}
          #{field_renders}
          #{submit_section}
        </form>
        #{progress_section}
        <div id="txtShow" class="navy bg-light-blue mw6 pa2"></div>
      HTML
    end

    # Set the CSRF tag.
    #
    # @return [void]
    def add_csrf_tag(value)
      @csrf_tag = value
    end

    # Render "previous" and "next" buttons.
    #
    # @param url [String] the url with "$:id$" in the place to put the next/prev id.
    # @param ids [Array] the id numbers in desired sequence.
    # @param current_id [Integer] the id in the URL of the current page.
    # @param options (Hash) options for the navigation buttons.
    # @option options [String] :prev_caption The caption to show on the previous button. Default "Previous"
    # @option options [String] :next_caption The caption to show on the next button. Default "Next"
    # @return [void]
    def add_prev_next_nav(url, ids, current_id, options = {}) # rubocop:disable Metrics/AbcSize
      curr_index = ids.index(current_id)
      have_prev = curr_index.positive?
      have_next = curr_index < ids.length - 1
      p_caption = options[:prev_caption] || 'Previous'
      n_caption = options[:next_caption] || 'Next'
      prev = if have_prev
               %(<a href="#{url.sub('$:id$', ids[curr_index - 1].to_s)}" class="dim link br2 pa2 bn white bg-dark-blue">&laquo; #{p_caption}</a>)
             else
               '&nbsp;'
             end
      nex = if have_next
              %(<a href="#{url.sub('$:id$', ids[curr_index + 1].to_s)}" class="dim link br2 pa2 bn white bg-dark-blue">#{n_caption} &raquo;</a>)
            else
              '&nbsp;'
            end
      @fields << <<~HTML
        <tr>
        <td class="pa2">#{prev}</td><td class="pa2">#{nex}</td>
        </tr>
      HTML
    end

    def behaviours
      raise ArgumentError, 'Behaviours must be defined before fields' unless @fields.empty?

      yield self
    end

    # ---------------------------------------------------------------------------------------------------
    # BEHAVIOURS - PARTS OF THIS CODE ARE ALSO IN UiRules AND PARTS IN Crossbeams::Layout::Renderer::Base
    # ---------------------------------------------------------------------------------------------------

    # 1) BEHAVIOUR (UiRules)
    # ======================
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

    def input_change(field_name, conditions = {})
      raise(ArgumentError, 'Input change behaviour requires `notify: url`.') if (conditions[:notify] || []).any? { |c| c[:url].nil? }

      @rules << { field_name => {
        input_change: (conditions[:notify] || []).map do |n|
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

    private

    def field_value(value)
      return value.to_s('F') if value.is_a?(BigDecimal)

      value
    end

    def initial_visibilty(options)
      return '' unless options[:hide_on_load]

      ' hidden'
    end

    def page_number_and_page_count
      return '' if @step_count.nil?

      %(<span class="mid-gray"> &ndash; (step #{@step_number} of #{@step_count})</span>)
    end

    def decimal_or_int(data_type, options)
      return '' unless data_type == 'number'
      return '' unless options[:allow_decimals]

      ' step="any"'
    end

    def lookup_data(options)
      return '' unless options[:lookup]

      ' data-lookup="Y"'
    end

    def lookup_display(name, options) # rubocop:disable Metrics/AbcSize
      return '' unless options[:lookup]

      <<~HTML
        <div id ="#{form_name}_#{name}_scan_lookup" class="b gray" data-lookup-result="Y" data-reset-value="#{form_state.fetch(:lookup_values, {})[name] || '&nbsp;'}">#{form_state.fetch(:lookup_values, {})[name] || '&nbsp;'}</div>
        <input id ="#{form_name}_#{name}_scan_lookup_hidden" type="hidden" data-lookup-hidden="Y" data-reset-value="#{form_state.fetch(:lookup_values, {})[name] || '&nbsp;'}" name="lookup_values[#{name}]" value="#{form_state.fetch(:lookup_values, {})[name]}">
      HTML
    end

    def hidden_label(name, hidden_value)
      value = hidden_value || form_state[name]
      return '' if value.nil?

      <<~HTML
        <input id ="#{form_name}_#{name}" type="hidden" name="#{form_name}[#{name}]" value="#{field_value(value)}">
      HTML
    end

    def submit_form(options)
      return '' unless options[:submit_form]

      ' data-submit-form="Y"'
    end

    def clear_button(for_scan)
      return '' if for_scan.empty?

      <<~HTML
        <button type="button" title="Clear input" class="pa2 white ba bw1 br1 b--silver dim dib f6 bg-silver rmdClear" data-rmd-clear="y">
          <svg class="cbl-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M0 10l7-7h13v14H7l-7-7zm14.41 0l2.13-2.12-1.42-1.42L13 8.6l-2.12-2.13-1.42 1.42L11.6 10l-2.13 2.12 1.42 1.42L13 11.4l2.12 2.13 1.42-1.42L14.4 10z"/></svg>
        </buton>
      HTML
    end

    def set_readonly(val, for_scan)
      return '' if for_scan.empty?
      return '' if val.nil?

      ' readonly'
    end

    # Set autofocus on fields in error, or else on the first field.
    def autofocus_for_field(name)
      if @form_state[:errors]
        if @form_state[:errors].key?(name)
          ' autofocus'
        else
          ''
        end
      else
        @fields.empty? ? ' autofocus' : ''
      end
    end

    def hidden_scan_type(name, options)
      return '' unless options[:scan]

      <<~HTML
        <input id="#{form_name}_#{name}_scan_field" type="hidden" name="#{form_name}[#{name}_scan_field]" value="#{form_state["#{name}_scan_field".to_sym]}">
      HTML
    end

    def field_renders
      <<~HTML
        <table class="rmd-table"><tbody>
          #{@fields.join("\n")}
        </tbody></table>
      HTML
    end

    def scan_opts(options)
      if options[:scan]
        %( data-scanner="#{options[:scan]}" data-scan-rule="#{options[:scan_type]}" autocomplete="off")
      else
        ''
      end
    end

    def field_error_state
      val = form_state[:errors] && form_state[:errors][@current_field]
      return '' unless val

      ' class="bg-washed-red"'
    end

    def field_error_message
      val = form_state[:errors] && form_state[:errors][@current_field]
      return '' unless val

      "<span class='brown'><br>#{val.compact.join('; ')}</span>"
    end

    def field_error_class
      val = form_state[:errors] && form_state[:errors][@current_field]
      return '' unless val

      ' bg-washed-red'
    end

    def field_upper_class(options)
      return '' unless options[:force_uppercase]

      ' cbl-to-upper'
    end

    def attr_upper(options)
      return '' unless options[:force_uppercase]

      %{ onblur="this.value = this.value.toUpperCase()"}
    end

    def error_section
      show_hide = form_state[:error_message] ? '' : ' hidden'
      <<~HTML
        <div id="rmd-error" class="brown bg-washed-red ba b--light-red pa3 mw6"#{show_hide}>
          #{(form_state[:error_message] || '').gsub("\n", '<br>')}
        </div>
      HTML
    end

    def progress_section
      show_hide = progress ? '' : ' style="display:none"'
      <<~HTML
        <div id="rmd-progress" class="white bg-blue ba b--navy mt1 pa3 mw6"#{show_hide}>
          #{progress}
        </div>
      HTML
    end

    def notes_section
      return '' unless notes

      "<p>#{notes.gsub("\n", '<br>')}</p>"
    end

    def submit_section
      return '' if @no_submit && @links.empty?
      return "<p>#{links_section}</p>" if @no_submit

      <<~HTML
        <p>
          <input type="submit" value="#{button_caption}" #{submit_id_str}data-disable-with="Submitting..." class="dim br2 pa3 bn white bg-green mr3" data-rmd-btn="Y"#{initial_hide}> #{buttons_section} #{links_section} #{reset_section}
        </p>
      HTML
    end

    def buttons_section
      return '' if @buttons.empty?

      @buttons.join(' ')
    end

    def initial_hide
      return '' unless @button_initially_hidden

      ' hidden'
    end

    def submit_id_str
      return '' unless @button_id

      %(id="#{@button_id}" )
    end

    def reset_section
      return '' unless @reset_button

      <<~HTML
        <input type="reset" class="dim br2 pa3 bn white bg-silver ml4" data-reset-rmd-form="Y">
      HTML
    end

    def links_section
      @links.map do |link|
        caption = link[:caption]
        url = link[:url]
        if link[:prompt]
          <<~HTML
            <a href="#{url}" class="dim link br2 pa3 bn white bg-dark-blue ml4" data-prompt="#{link[:prompt]}">#{caption}</a>
          HTML
        else
          <<~HTML
            <a href="#{url}" class="dim link br2 pa3 bn white bg-dark-blue ml4">#{caption}</a>
          HTML
        end
      end.join
    end

    def camera_section
      return '' unless scan_with_camera

      <<~HTML
        <button id="cameraScan" type="button" class="dim br2 pa3 bn white bg-blue">
          #{Crossbeams::Layout::Icon.render(:camera)} Scan with camera
        </button>
        <button id="cameraLight" type="button" class="dim br2 pa3 bn white bg-blue">
          #{Crossbeams::Layout::Icon.render(:show)} Light On/Off
        </button>
      HTML
    end

    def make_prompt(prompt)
      return '' if prompt.nil?

      str = prompt.is_a?(String) ? prompt : 'Select a value'
      "<option value=\"\">#{str}</option>\n"
    end

    def build_options(list, selected)
      if list.is_a?(Hash)
        opts = []
        list.each do |group, sublist|
          opts << %(<optgroup label="#{group}">)
          opts << make_options(Array(sublist), selected)
          opts << '</optgroup>'
        end
        opts.join("\n")
      else
        make_options(Array(list), selected)
      end
    end

    def make_options(list, selected)
      opts = list.map do |a|
        a.is_a?(Array) ? option_string(a.first, a.last, selected) : option_string(a, a, selected)
      end
      opts.join("\n")
    end

    def option_string(text, value, selected)
      sel = selected && value.to_s == selected.to_s ? ' selected ' : ''
      "<option value=\"#{CGI.escapeHTML(value.to_s)}\"#{sel}>#{CGI.escapeHTML(text.to_s)}</option>"
    end

    # False if value is nil, false or starts with f, n or 0.
    # Else true.
    def checked(value)
      false_str = value.to_s.match?(/[nf0]/i)
      value && value != false && !false_str ? ' checked' : ''
    end

    # ---------------------------------------------------------------------------------------------------
    # BEHAVIOURS - PARTS OF THIS CODE ARE ALSO IN UiRules AND PARTS IN Crossbeams::Layout::Renderer::Base
    # ---------------------------------------------------------------------------------------------------

    # 2) BEHAVIOUR (Crossbeams::Layout::Renderer::Base)
    # =================================================

    # Return behaviour rules for rendering.
    def render_behaviours # rubocop:disable Metrics/AbcSize
      return nil if rules.nil?

      res = []
      rules.each do |element|
        element.each do |field, rule|
          res << build_behaviour(rule) if field == @current_field
        end
      end
      return nil if res.empty?

      keys = res.map { |r| r[/\A.+=/].chomp('=') }
      raise ArgumentError, "Renderer: cannot have more than one of the same behaviour for field \"#{@current_field}\"" unless keys.length == keys.uniq.length

      res.join(' ')
    end

    def build_behaviour(rule) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      return %(data-change-values="#{split_change_affects(rule[:change_affects])}") if rule[:change_affects]
      return %(data-enable-on-values="#{rule[:enable_on_change].join(',')}") if rule[:enable_on_change]
      return %(data-observe-selected=#{build_observe_selected(rule[:populate_from_selected])}) if rule[:populate_from_selected]
      return %(data-observe-change=#{build_observe_change(rule[:notify])}) if rule[:notify]
      return %(data-observe-keyup=#{build_observe_change(rule[:keyup])}) if rule[:keyup]
      return %(data-observe-input-change=#{build_observe_change(rule[:input_change])}) if rule[:input_change]
      return %(data-observe-lose-focus=#{build_observe_change(rule[:lose_focus])}) if rule[:lose_focus]
    end

    def split_change_affects(change_affects)
      change_affects.split(';').map { |c| "#{form_name}_#{c}" }.join(',')
    end

    def build_observe_change(notify_rules)
      combined = notify_rules.map do |rule|
        %({"url":"#{rule[:url]}","param_keys":#{param_keys_str(rule)},"param_values":{#{param_values_str(rule)}}})
      end.join(',')
      %('[#{combined}]')
    end

    def build_observe_selected(selected_rules)
      combined = selected_rules.map do |rule|
        %({"sortable":"#{rule[:sortable]}"})
      end.join(',')
      %('[#{combined}]')
    end

    def param_keys_str(rule)
      rule[:param_keys].nil? || rule[:param_keys].empty? ? '[]' : %(["#{rule[:param_keys].join('","')}"])
    end

    def param_values_str(rule)
      rule[:param_values].map { |k, v| "\"#{k}\":\"#{v}\"" }.join(',')
    end
  end
end
