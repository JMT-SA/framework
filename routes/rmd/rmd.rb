# frozen_string_literal: true

class Framework < Roda
  route 'home', 'rmd' do # |r|
    # show the full menu
    @no_menu = true
    show_rmd_page { Rmd::Home::Show.call(rmd_menu_items(self.class.name, as_hash: true)) }
  end

  route 'websocket_result', 'rmd' do # |r|
    p params
    s = <<-HTML
    <h1>Websocket parameter results</h1>
    <table>
    <tr><th>Param</th><th>Value</th></tr>
    #{params.map { |k, v| "<tr><td>#{k}</td><td style='padding:8px;background-color:#ddd'><strong>#{v.gsub(/\n/, '<br>')}</strong></td></tr>" }.join}
    </table>
    HTML
    view(inline: s, layout: :layout_rmd)
  end

  # put-away delivery
  # - delivery created with items and SKU's
  # - SKU labels printed (print from rmd?)
  # pg1: select delivery.
  # pg2: scan SKU & qty (per delivery item?)
  route 'deliveries', 'rmd' do |r|
    # REGISTERED MOBILE DEVICES
    # --------------------------------------------------------------------------
    # r.on 'putaway', Integer do # |id| # could be more generic...
    r.on 'putaway' do # |id| # could be more generic...
      html = <<~HTML
        <h2>Delivery putaway</h2>
        <form action="/rmd/websocket_result">
          <p>
            Scan the location, then the SKU and enter the quantity.
          </p>
          <table><tbody>
            <tr><th align="left">Location</th>
            <td><input class="pa2" id="location" type="text" name="location" placeholder="Scan Location" data-scanner="key248_all" data-scan-rule="location" autocomplete="off"></td></tr>
          </tr>
            <tr><th align="left">SKU</th>
            <td><input class="pa2" id="sku" type="text" name="sku" placeholder="Scan SKU" data-scanner="key248_all" data-scan-rule="sku" autocomplete="off"></td></tr>
          </tr>
            <tr><th align="left">Quantity</th>
            <td><input class="pa2" id="quantity" type="number" name="quantity" placeholder="enter QTY" step="1"></td></tr>
          </tr>
          </tbody></table>
          <p>
            <input type="submit" value="Putaway" class="dim br2 pa3 bn white bg-green">
          </p>
        </form>
        <textarea id="txtShow" style="background-color:darkseagreen;color:navy" rows="20", cols="35" readonly></textarea>
      HTML
      view(inline: html, layout: :layout_rmd)
    end

    r.on 'status' do
      view(inline: '<h2>Just a dummy page this...</h2><p>Nothing to see here, keep moving along...</p>', layout: :layout_rmd)
    end
  end
end
