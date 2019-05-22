# frozen_string_literal: true

class Framework < Roda
  # RMD USER MENU PAGE
  # --------------------------------------------------------------------------
  route 'home', 'rmd' do # |r|
    @no_menu = true
    show_rmd_page { Rmd::Home::Show.call(rmd_menu_items(self.class.name, as_hash: true)) }
  end

  # RMD BARCODE CHECK PAGE
  # --------------------------------------------------------------------------
  route 'utilities', 'rmd' do |r| # rubocop:disable Metrics/BlockLength
    r.is 'check_barcode' do # # rubocop:disable Metrics/BlockLength
      r.get do
        form = Crossbeams::RMDForm.new({},
                                       form_name: :barcodes,
                                       notes: 'Scan one or more barcodes to see their raw text',
                                       scan_with_camera: @rmd_scan_with_camera,
                                       caption: 'Barcode check',
                                       action: '/rmd/utilities/check_barcode',
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
            <a href="/rmd/utilities/check_barcode" class="link dim br2 pa3 bn white bg-blue">Scan again</a>
          </p>
        HTML
        view(inline: "<h2>Scanned barcodes</h2><p>#{res}</p>", layout: :layout_rmd)
      end
    end

    # RMD TOGGLE CAMERA-SCAN ON AND OFF
    # --------------------------------------------------------------------------
    r.is 'toggle_camera' do
      r.get do
        if @registered_mobile_device
          form = Crossbeams::RMDForm.new({},
                                         form_name: :camera_scan,
                                         notes: "The camera scan option is #{@rmd_scan_with_camera ? 'ON' : 'OFF'}",
                                         scan_with_camera: @rmd_scan_with_camera,
                                         caption: 'Toggle camera scan',
                                         action: '/rmd/utilities/toggle_camera',
                                         button_caption: @rmd_scan_with_camera ? 'Turn camera OFF' : 'Turn camera ON')
          form.add_csrf_tag csrf_tag
          @bypass_rules = true
          view(inline: form.render, layout: :layout_rmd)
        else
          view(inline: wrap_content_in_style("This ip address (#{request.ip}) is not an active Registered Mobile Device", :error), layout: :layout_rmd)
        end
      end
      r.post do
        interactor = SecurityApp::RegisteredMobileDeviceInteractor.new(current_user, {}, { route_url: request.path }, {})
        res = interactor.toggle_camera_scan(request.ip)
        if res.success
          r.redirect '/rmd/utilities/toggle_camera'
        else
          view(inline: wrap_content_in_style(res.message, :warning), layout: :layout_rmd)
        end
      end
    end
  end
end
