# frozen_string_literal: true

class Framework < Roda
  class RMDForm
    attr_reader :form_state, :progress, :notes, :scan_with_camera, :caption, :action, :button_caption, :csrf_tag

    def initialize(form_state, options)
      @form_state = form_state
      @progress = options[:progress]
      @notes = options[:notes]
      @scan_with_camera = options[:scan_with_camera] == true
      @caption = options[:caption]
      @action = options[:action]
      @button_caption = options[:button_caption]
      @fields = []
      @csrf_tag = nil
    end

    def add_field(name, label, options)
      @current_field = name
      for_scan = options[:scan] ? 'Scan ' : ''
      data_type = options[:data_type] || 'text'
      required = options[:required].nil? || options[:required] ? ' required' : ''
      autofocus = autofocus_for_field(name)
      @fields << <<~HTML
        <tr#{field_error_state}><th align="left">#{label}#{field_error_message}</th>
        <td><input class="pa2#{field_error_class}" id="#{name}" type="#{data_type}" name="#{name}" placeholder="#{for_scan}#{label}"#{scan_opts(options)} value="#{form_state[name]}"#{required}#{autofocus}>
        </td></tr>
      HTML
    end

    def render
      raise ArgumentError, 'RMDForm: no CSRF tag provided' if csrf_tag.nil?
      <<~HTML
        <h2>#{caption}</h2>
        <form action="#{action}" method="POST">
          #{error_section}
          #{notes_section}
          #{camera_section}
          #{csrf_tag}
          #{field_renders}
          #{submit_section}
        </form>
        #{progress_section}
        <textarea id="txtShow" class="navy bg-light-blue" rows="20", cols="35" readonly></textarea>
      HTML
    end

    def add_csrf_tag(value)
      @csrf_tag = value
    end

    private

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

    def field_renders
      <<~HTML
        <table><tbody>
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

    def error_section
      show_hide = form_state[:error_message] ? '' : ' style="display:none"'
      <<~HTML
        <div id="rmd-error" class="brown bg-washed-red ba b--light-red pa3 mw6"#{show_hide}>
          #{form_state[:error_message]}
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
      "<p>#{notes}</p>"
    end

    def submit_section
      <<~HTML
        <p>
          <input type="submit" value="#{button_caption}" class="dim br2 pa3 bn white bg-green" data-rmd-btn="Y">
        </p>
      HTML
    end

    def camera_section
      return '' unless scan_with_camera
      <<~HTML
        <button id="cameraScan" type="button" class="dim br2 pa3 bn white bg-blue">
          #{Crossbeams::Layout::Icon.render(:camera)} Scan with camera
        </button>
      HTML
    end
  end

  # RMD USER MENU PAGE
  # --------------------------------------------------------------------------
  route 'home', 'rmd' do # |r|
    @no_menu = true
    show_rmd_page { Rmd::Home::Show.call(rmd_menu_items(self.class.name, as_hash: true)) }
  end

  # DELIVERIES
  # --------------------------------------------------------------------------
  route 'deliveries', 'rmd' do |r| # rubocop:disable Metrics/BlockLength
    # PUTAWAYS
    # --------------------------------------------------------------------------
    r.on 'putaways' do # rubocop:disable Metrics/BlockLength
      # Interactor
      r.on 'new' do    # NEW
        # check auth...
        details = retrieve_from_local_store(:delivery_putaway) || {}
        form = RMDForm.new(details,
                           progress: details[:delivery_id] ? details[:progress] : nil, # 'Delivery 123: 3 of 5 items complete' : nil,
                           notes: 'Scan the location, then the SKU and enter the quantity.',
                           scan_with_camera: @rmd_scan_with_camera,
                           caption: 'Delivery putaway',
                           action: '/rmd/deliveries/putaways',
                           button_caption: 'Putaway')
        form.add_field(:location, 'Location', scan: 'key248_all', scan_type: :location)
        form.add_field(:sku, 'SKU', scan: 'key248_all', scan_type: :sku)
        form.add_field(:quantity, 'Quantity', data_type: 'number')
        form.add_csrf_tag csrf_tag
        view(inline: form.render, layout: :layout_rmd)
      end

      r.post do        # CREATE
        # res = interactor.create_putaway...
        # Simulate interactor call:
        instance = { delivery_id: 123 }
        res = if Time.now.sec > 40
                OpenStruct.new(success: false,
                               instance: instance.merge(progress: 'Delivery 123: 2 of 5 items.'),
                               errors: { sku: ['is not correct'] },
                               message: 'Validation problem')
              else
                OpenStruct.new(success: true,
                               instance: instance.merge(progress: "Delivery 123: 3 of 5 items.<br>Last scan: LOC: #{params[:location]} / SKU: #{params[:sku]}"),
                               errors: {},
                               message: 'Successful putaway')
              end
        payload = { delivery_id: 123, progress: res.instance[:progress] }
        unless res.success
          payload[:error_message] = res.message
          payload[:errors] = res.errors
          payload.merge!(location: params[:location], sku: params[:sku], quantity: params[:quantity])
        end
        store_locally(:delivery_putaway, payload)
        r.redirect '/rmd/deliveries/putaways/new'
      end
    end

    r.on 'status' do
      view(inline: '<h2>Just a dummy page this...</h2><p>Nothing to see here, keep moving along...</p>', layout: :layout_rmd)
    end
  end
end
