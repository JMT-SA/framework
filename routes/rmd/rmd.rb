# frozen_string_literal: true

class Framework < Roda
  route 'home', 'rmd' do # |r|
    # show the full menu
    @no_menu = true
    show_rmd_page { Rmd::Home::Show.call(rmd_menu_items(self.class.name, as_hash: true)) }
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
      view(inline: 'THE RMD DELIVERY PUTAWAY', layout: :layout_rmd)
    end
  end
end
