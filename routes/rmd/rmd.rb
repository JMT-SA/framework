# frozen_string_literal: true

class Framework < Roda
  class RMDForm # rubocop:disable Metrics/ClassLength
    attr_reader :form_state, :form_name, :progress, :notes, :scan_with_camera,
                :caption, :action, :button_caption, :csrf_tag

    def initialize(form_state, options)
      @form_state = form_state
      @form_name = options.fetch(:form_name)
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
        <td><input class="pa2#{field_error_class}" id="#{form_name}_#{name}" type="#{data_type}" name="#{form_name}[#{name}]" placeholder="#{for_scan}#{label}"#{scan_opts(options)} value="#{form_state[name]}"#{required}#{autofocus}>#{hidden_scan_type(name, options)}
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
        <div id="txtShow" class="navy bg-light-blue mw6 pa2"></div>
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

    def hidden_scan_type(name, options)
      return '' unless options[:scan]
      <<~HTML
        <input id="#{form_name}_#{name}_scan_field" type="hidden" name="#{form_name}[#{name}_scan_field]" value="#{form_state["#{name}_scan_field".to_sym]}">
      HTML
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
          <input type="submit" value="#{button_caption}" data-disable-with="Submitting..." class="dim br2 pa3 bn white bg-green" data-rmd-btn="Y">
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

  # RMD BARCODE CHECK PAGE
  # --------------------------------------------------------------------------
  route 'check_barcode', 'rmd' do |r| # rubocop:disable Metrics/BlockLength
    r.get do
      form = RMDForm.new({},
                         form_name: :barcodes,
                         notes: 'Scan one or more barcodes to see their raw text',
                         scan_with_camera: @rmd_scan_with_camera,
                         caption: 'Barcode check',
                         action: '/rmd/check_barcode',
                         button_caption: 'Show')
      form.add_field(:barcode_1, 'Barcode one', scan: 'key248_all', required: false)
      form.add_field(:barcode_2, 'Barcode two', scan: 'key248_all', required: false)
      form.add_field(:barcode_3, 'Barcode three', scan: 'key248_all', required: false)
      form.add_field(:barcode_4, 'Barcode four', scan: 'key248_all', required: false)
      form.add_field(:barcode_5, 'Barcode five', scan: 'key248_all', required: false)
      form.add_csrf_tag csrf_tag
      @bypass_rules = true
      view(inline: form.render, layout: :layout_rmd)
    end
    r.post do
      tr_cls = 'striped--light-gray'
      td_cls = 'pv2 ph3'
      res = <<~HTML
        <table class="collapse ba br2 b--black-10 pv2 ph3">
        <tbody>
          <tr class="#{tr_cls}"><td class="#{td_cls}">Barcode one</td><td class="#{td_cls}">#{params[:barcodes][:barcode_1]}</td></tr>
          <tr class="#{tr_cls}"><td class="#{td_cls}">Barcode two</td><td class="#{td_cls}">#{params[:barcodes][:barcode_2]}</td></tr>
          <tr class="#{tr_cls}"><td class="#{td_cls}">Barcode three</td><td class="#{td_cls}">#{params[:barcodes][:barcode_3]}</td></tr>
          <tr class="#{tr_cls}"><td class="#{td_cls}">Barcode four</td><td class="#{td_cls}">#{params[:barcodes][:barcode_4]}</td></tr>
          <tr class="#{tr_cls}"><td class="#{td_cls}">Barcode five</td><td class="#{td_cls}">#{params[:barcodes][:barcode_5]}</td></tr>
        </tbody>
        </table>
        <p class="mt4">
          <a href="/rmd/check_barcode" class="link dim br2 pa3 bn white bg-blue">Scan again</a>
        </p>
      HTML
      view(inline: "<h2>Scanned barcodes</h2><p>#{res}</p>", layout: :layout_rmd)
    end
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
                           form_name: :putaway,
                           progress: details[:delivery_id] ? details[:progress] : nil, # 'Delivery 123: 3 of 5 items complete' : nil,
                           notes: 'Please scan the Delivery number and the SKU number, then scan the Location and enter the quantity to be putaway.',
                           scan_with_camera: @rmd_scan_with_camera,
                           caption: 'Delivery putaway',
                           action: '/rmd/deliveries/putaways',
                           button_caption: 'Putaway')
        form.add_field(:delivery_number, 'Delivery', scan: 'key248_all', scan_type: :delivery)
        form.add_field(:sku_number, 'SKU', scan: 'key248_all', scan_type: :sku)
        form.add_field(:location, 'Location', scan: 'key248_all', scan_type: :location)
        form.add_field(:quantity, 'Quantity', data_type: 'number')
        form.add_csrf_tag csrf_tag
        view(inline: form.render, layout: :layout_rmd)
      end

      r.post do        # CREATE
        interactor = PackMaterialApp::MrDeliveryInteractor.new(current_user, {}, { route_url: request.path }, {})
        res = interactor.putaway_delivery(params[:putaway])
        payload = { progress: nil }
        if res.success
          payload[:delivery_id] = res.instance[:delivery_id]
          payload[:progress] = res.instance[:report]
        else
          these_params = params[:putaway]
          payload[:error_message] = res.message
          payload[:errors] = res.errors
          payload.merge!(location: these_params[:location],
                         location_scan_field: these_params[:location_scan_field],
                         sku_number: these_params[:sku_number],
                         sku_number_scan_field: these_params[:sku_number_scan_field],
                         delivery_number: these_params[:delivery_number],
                         delivery_number_scan_field: these_params[:delivery_number_scan_field],
                         quantity: these_params[:quantity])
        end

        store_locally(:delivery_putaway, payload)
        r.redirect '/rmd/deliveries/putaways/new'
      end
    end

    r.on 'status' do
      view(inline: '<h2>Just a dummy page this...</h2><p>Nothing to see here, keep moving along...</p>', layout: :layout_rmd)
    end
  end

  # Bulk Stock Adjustments
  # --------------------------------------------------------------------------
  route 'stock_adjustments', 'rmd' do |r| # rubocop:disable Metrics/BlockLength
    # ADJUST ITEM
    # --------------------------------------------------------------------------
    r.on 'adjust_item' do # rubocop:disable Metrics/BlockLength
      interactor = PackMaterialApp::MrBulkStockAdjustmentInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do
        details = retrieve_from_local_store(:stock_item_adjustment) || {}
        form = RMDForm.new(details,
                           form_name: :adjust_item,
                           progress: details[:bulk_stock_adjustment_id] ? details[:progress] : nil,
                           notes: 'Please scan the Stock Adjustment number and the SKU number, then scan the Location and enter the actual quantity to adjust the item.',
                           scan_with_camera: @rmd_scan_with_camera,
                           caption: 'Stock Item Adjustment',
                           action: '/rmd/stock_adjustments/adjust_item',
                           button_caption: 'Adjust Item')
        form.add_field(:stock_adjustment_number, 'Stock Adjustment', scan: 'key248_all', scan_type: :stock_adjustment)
        form.add_field(:sku_number, 'SKU', scan: 'key248_all', scan_type: :sku)
        form.add_field(:location, 'Location', scan: 'key248_all', scan_type: :location)
        form.add_field(:quantity, 'Actual Quantity', data_type: 'number')
        form.add_csrf_tag csrf_tag
        view(inline: form.render, layout: :layout_rmd)
      end

      r.post do
        res = interactor.stock_item_adjust(params[:adjust_item])
        payload = { progress: nil }
        if res.success
          payload[:bulk_stock_adjustment_id] = res.instance[:bulk_stock_adjustment_id]
          payload[:stock_adjustment_number] = params[:adjust_item][:stock_adjustment_number]
          payload[:stock_adjustment_number_scan_field] = params[:adjust_item][:stock_adjustment_number_scan_field]
          payload[:progress] = res.instance[:report]
        else
          these_params = params[:adjust_item]
          payload[:error_message] = res.message
          payload[:errors] = res.errors
          payload.merge!(location: these_params[:location],
                         location_scan_field: these_params[:location_scan_field],
                         sku_number: these_params[:sku_number],
                         sku_number_scan_field: these_params[:sku_number_scan_field],
                         stock_adjustment_number: these_params[:stock_adjustment_number],
                         stock_adjustment_number_scan_field: these_params[:stock_adjustment_number_scan_field],
                         quantity: these_params[:quantity])
        end

        store_locally(:stock_item_adjustment, payload)
        r.redirect '/rmd/stock_adjustments/adjust_item/new'
      end
    end
  end
end
