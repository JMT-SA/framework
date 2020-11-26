# frozen_string_literal: true

module PackMaterialApp
  class WaCostRepo < BaseRepo
    def calculate_wa_costs
      pv_ids = DB[:material_resource_product_variants].select_map(:id)
      pv_ids.each do |pv_id|
        cost = wa_cost(pv_id) || BigDecimal('0')
        DB[:material_resource_product_variants].where(id: pv_id).update(weighted_average_cost: cost)
      end
    end

    def update_wa_cost(mrpv_id)
      cost = wa_cost(mrpv_id) || BigDecimal('0')
      DB[:material_resource_product_variants].where(id: mrpv_id).update(weighted_average_cost: cost)
    end

    def wa_cost_for_sku_id(sku_id)
      pv_id = DB[:mr_skus].where(id: sku_id).get(:mr_product_variant_id)
      wa_cost(pv_id)
    end

    def wa_cost_records_for_variant(mrpv_id)
      weighted_average_cost_records.select { |r| r[:mr_product_variant_id] == mrpv_id }
    end

    def wa_cost(mrpv_id) # rubocop:disable Metrics/AbcSize
      # Only do the calculation if there is stock
      total_qty = total_quantity(mrpv_id)
      p 'TOTAL QTY'
      p total_qty.to_f
      return nil unless total_qty&.positive?

      rest = total_qty
      total_amt = 0
      records = wa_cost_records_for_variant(mrpv_id)
      # for each record
      fix_remainder = 0
      records.each do |r|
        # ignore record if it does not have a price set
        # ignore record if it is a consumption record
        next if r[:price].nil? || r[:price].eql?(0) || (r[:quantity].negative? && r[:record_type] == 'bulk stock adjustment item')

        # grab the qty
        # Note: we expect some negative quantities from the vw
        qty = r[:quantity]
        p qty.to_f
        # puts "#{qty.to_f},#{r[:price].to_f}"
        p "Whole qty: #{qty.to_f}"
        # records are ordered by latest first
        # ensure that the record is valid by checking that it does not exceed the qty we have in stock
        rest -= qty.abs

        p "rest #{rest.to_f}"
        p "type: #{r[:record_type]}"
        p "price: #{r[:price].to_f} (next if nil)"

        # Determine the applicable qty:
        applicable_qty = rest.negative? ? (r[:quantity] + rest) : r[:quantity]
        fix_remainder = rest * r[:price]
        p "appl qty #{applicable_qty.to_f}"

        # Calculate amt = factor * price * applicable qty
        amt = applicable_qty * r[:price] # * r[:factor]
        p "amt #{amt.to_f}"

        fix_remainder -= amt

        total_amt += amt
        p "total amt #{total_amt.to_f}"
        p '----------------------------------------'
        break if rest.negative? || rest.eql?(0)
      end
      total_amt += fix_remainder if rest.positive?
      total_amt / total_qty
    end

    def total_quantity(mrpv_id)
      DB[:mr_sku_locations].where(mr_sku_id: DB[:mr_skus].where(mr_product_variant_id: mrpv_id).select_map(:id)).sum(:quantity)
    end

    def weighted_average_cost_records
      DB[:vw_weighted_average_cost_records].all
    end

    def wa_cost_records
      DB["select vw.mr_product_variant_id,
                 mrpv.product_variant_code,
                 vw.sku_number,
                 vw.sku_id,
                 vw.id as applicable_id,
                 vw.quantity,
                 vw.record_type,
                 vw.price,
                 vw.actioned_at
          from vw_weighted_average_cost_records vw
          left join material_resource_product_variants mrpv on vw.mr_product_variant_id = mrpv.id;"].all
    end
  end
end
