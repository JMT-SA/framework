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

    def wa_cost_for_sku_id(sku_id)
      pv_id = DB[:mr_skus].where(id: sku_id).get(:mr_product_variant_id)
      wa_cost(pv_id)
    end

    def wa_cost_records_for_variant(mrpv_id)
      weighted_average_cost_records.select { |r| r[:mr_product_variant_id] == mrpv_id }
    end

    def wa_cost(mrpv_id) # rubocop:disable Metrics/AbcSize
      total_qty = total_quantity(mrpv_id)
      return nil unless total_qty

      rest = total_qty
      total_amt = 0
      records = wa_cost_records_for_variant(mrpv_id)
      records.each do |r|
        qty = r[:quantity]
        rest -= qty.abs
        next if r[:price].nil?

        amt = (rest.positive? || rest.zero? ? r[:quantity] : rest.abs) * r[:price]
        total_amt += amt
        break if rest.negative?
      end
      total_amt / total_qty
    end

    def total_quantity(mrpv_id)
      DB[:mr_sku_locations].where(mr_sku_id: DB[:mr_skus].where(mr_product_variant_id: mrpv_id).select_map(:id)).sum(:quantity)
    end

    def weighted_average_cost_records
      DB[:vw_weighted_average_cost_records].all
    end
  end
end
