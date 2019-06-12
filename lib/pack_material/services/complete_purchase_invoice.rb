# frozen_string_literal: true

module PackMaterialApp
  class CompletePurchaseInvoice < BaseService
    # @param [Integer] delivery_id
    def initialize(user_name, delivery_id, block = nil)
      @block = block
      @repo           = PurchaseInvoiceRepo.new
      @replenish_repo = ReplenishRepo.new
      @user_name      = user_name
      @id             = delivery_id
      @delivery       = @repo.find_mr_delivery(@id)
    end

    def call
      return failed_response('Delivery does not exist') unless @repo.exists?(:mr_deliveries, id: @id)

      request_xml = build_xml
      res = make_http_call(request_xml)
      formatted_res = format_response(res.instance.body)

      @repo.transaction do
        if formatted_res.success
          @replenish_repo.delivery_complete_invoice(@id, formatted_res.instance)
          @repo.log_status('mr_deliveries', @id, 'PURCHASE INVOICE COMPLETED', user_name: @user_name)
        else
          @replenish_repo.update_mr_delivery(@id, invoice_error: true)
          @repo.log_status('mr_deliveries', @id, formatted_res.message, user_name: @user_name)
        end
        @block&.call
      end
    end

    def build_xml # rubocop:disable Metrics/AbcSize
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
      request_xml.to_xml
    end

    def make_http_call(xml)
      http = Crossbeams::HTTPCalls.new
      res  = http.xml_post(AppConst::ERP_PURCHASE_INVOICE_URI, xml)
      raise Crossbeams::InfoError, res.message unless res.success

      res
    end

    def format_response(response)
      resp = Nokogiri::XML(response)
      message = resp.xpath('//error').text
      instance = {
        purchase_order_number: resp.xpath('//purchase_order_number').text,
        purchase_invoice_number: resp.xpath('//purchase_invoice_number').text
      }
      if message.empty?
        success_response('ok', instance)
      else
        failed_response(message, instance)
      end
    end
  end
end
