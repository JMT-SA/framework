# frozen_string_literal: true

Dir['./routes/pdt/*.rb'].each { |f| require f }

class Framework < Roda
  route('pdt') do |r|
    # store_current_functional_area('security') --- this is important for auth checks, but pdt auth different?
    # (hide pdt menu items)
    r.on 'home' do
      view(inline: 'THE PDT HOME PAGE', layout: :layout_mobile)
    end

    r.multi_route('pdt')
    # put-away delivery
    # - delivery created with items and SKU's
    # - SKU labels printed (print from pdt?)
    # pg1: select delivery.
    # pg2: scan SKU & qty (per delivery item?)
  end
end
