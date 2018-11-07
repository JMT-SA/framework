# frozen_string_literal: true

Dir['./routes/rmd/*.rb'].each { |f| require f }

class Framework < Roda
  route('rmd') do |r|
    # store_current_functional_area('security') --- this is important for auth checks, but rmd auth different?
    # (hide rmd menu items)
    r.on 'home' do
      view(inline: 'THE RMD HOME PAGE', layout: :layout_rmd)
    end

    r.multi_route('rmd')
    # put-away delivery
    # - delivery created with items and SKU's
    # - SKU labels printed (print from rmd?)
    # pg1: select delivery.
    # pg2: scan SKU & qty (per delivery item?)
  end
end
