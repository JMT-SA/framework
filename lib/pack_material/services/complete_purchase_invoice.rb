# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize

module PackMaterialApp
  class CompletePurchaseInvoice < BaseService
    # @param [Integer] delivery_id
    def initialize(delivery_id)
      @repo = PurchaseInvoiceRepo.new
      @id = delivery_id
      @delivery = @repo.find_mr_delivery(@id)
    end

    def call
      return failed_response('Delivery does not exist') unless @repo.exists?(:mr_deliveries, id: @id)

      # Deliveries are limited to single suppliers
      delivery_number = @delivery.delivery_number
      supplier_invoice_number = @delivery.supplier_invoice_ref_number
      supplier_invoice_date = @delivery.supplier_invoice_date.to_s

      supplier_code = @repo.get_supplier_erp_number(@id)

      costs = @repo.costs_for_delivery(@id)
      products = @repo.products_for_delivery(@id)


      request_xml = Nokogiri::XML::Builder.new do |xml|
        xml.purchase_invoice do
          xml.supplier_invoice_number supplier_invoice_number
          xml.supplier_invoice_date supplier_invoice_date.to_s
          xml.internal_invoice_number delivery_number
          xml.supplier_code supplier_code
          xml.costs do
            costs.each do |cost|
              xml.cost do
                xml.cost_code cost[:cost_code]
                xml.amount cost[:amount]
              end
            end
          end
          xml.line_items do
            products.each do |line_item|
              xml.line_item do
                xml.product_number line_item[:product_number]
                xml.product_description line_item[:product_description]
                xml.unit_price line_item[:unit_price]
                xml.quantity line_item[:quantity]
                xml.purchase_order_number line_item[:purchase_order_number]
              end
            end
          end
        end
      end
      uri = @repo.erp_integration_uri

      http = Crossbeams::HTTPCalls.new
      res = http.xml_post(uri, request_xml.to_xml)
      return res unless res.success

      instance = @repo.format_response(res.instance.body)
      success_response('Purchase Invoice Sent', instance)
    end
  end
end