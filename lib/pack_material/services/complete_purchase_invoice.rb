# frozen_string_literal: true

module PackMaterialApp
  class CompletePurchaseInvoice < BaseService # rubocop:disable Metrics/ClassLength
    # Complete a purchase invoice and send XML representation to accounting system.
    # - use the `just_show_xml` flag to check the XML output without modifying the db.
    #
    # @param user_name [string] the user who initiated this task.
    # @param opts [Hash] { delivery_id [integer], mr_goods_returned_note_id [integer] }
    # @param just_show_xml [bool] set to true to just return XML from the call without updating the db.
    def initialize(user_name, just_show_xml = false, block = nil, opts = {}) # rubocop:disable Metrics/AbcSize
      @block = block
      @repo = PurchaseInvoiceRepo.new
      @replenish_repo = ReplenishRepo.new
      @dispatch_repo = DispatchRepo.new
      @purchase_invoice_repo = PurchaseInvoiceRepo.new
      @log_repo = DevelopmentApp::LoggingRepo.new
      @user_name = user_name
      @grn_id = opts[:mr_goods_returned_note_id]
      @id = opts[:delivery_id]
      @just_show_xml = just_show_xml

      @goods_returned_note = @dispatch_repo.find_mr_goods_returned_note(@grn_id) if @grn_id
      @id ||= @goods_returned_note&.mr_delivery_id
      @delivery = @repo.find_mr_delivery(@id)
    end

    def call # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize
      return failed_response('Delivery does not exist') unless @repo.exists?(:mr_deliveries, id: @id)
      return failed_response('GRN does not exist') if @grn_id && !@dispatch_repo.exists?(:mr_goods_returned_notes, id: @grn_id)

      request_xml = @grn_id ? build_grn_xml : build_xml
      return request_xml if @just_show_xml

      log_string = @grn_id ? '_cn_xml' : '_xml'
      @log_repo.log_infodump('complete_purchase_invoice', @id, 'sending' + log_string, request_xml)

      res = make_http_call(request_xml)
      @log_repo.log_infodump('complete_purchase_invoice', @id, 'response' + log_string, res.instance.body)

      formatted_res = format_response(res.instance.body)
      @grn_id ? apply_grn_changes(formatted_res) : apply_delivery_changes(formatted_res)
    end

    private

    def build_grn_xml # rubocop:disable Metrics/AbcSize
      # Deliveries are limited to single suppliers
      # delivery_number = @delivery.delivery_number
      supplier_invoice_number = @delivery.supplier_invoice_ref_number
      supplier_invoice_date = @delivery.supplier_invoice_date.to_s
      supplier_code = @repo.get_supplier_erp_number(@id)
      po_account_code = @repo.po_account_code_for_delivery(@id)

      cn_number = @goods_returned_note.credit_note_number
      products = @purchase_invoice_repo.products_for_goods_returned_note(@grn_id)
      cn_totals = @purchase_invoice_repo.cn_sub_totals(@grn_id, delimiter: '', no_decimals: 5)

      request_xml = Nokogiri::XML::Builder.new do |xml|
        xml.purchase_invoice do
          xml.supplier_invoice_number supplier_invoice_number
          xml.supplier_invoice_date supplier_invoice_date
          xml.internal_invoice_number cn_number
          # xml.internal_invoice_number delivery_number
          # xml.credit_note_number cn_number
          xml.supplier_code supplier_code
          xml.account_code po_account_code
          xml.invoice_total cn_totals[:total]
          xml.subtotal cn_totals[:subtotal]
          xml.vat cn_totals[:vat]
          xml.pay_term 'CN'
          xml.line_items do
            products.each do |line_item|
              xml.line_item do
                xml.product_number line_item[:product_number]
                xml.product_description line_item[:product_description]
                xml.unit_price UtilityFunctions.delimited_number(line_item[:unit_price], delimiter: '', no_decimals: 5)
                xml.quantity UtilityFunctions.delimited_number(line_item[:quantity], delimiter: '', no_decimals: 2)
                xml.purchase_order_number line_item[:purchase_order_number]
              end
            end
          end
        end
      end
      request_xml.to_xml
    end

    def build_xml # rubocop:disable Metrics/AbcSize
      # Deliveries are limited to single suppliers
      delivery_number = @delivery.delivery_number
      supplier_invoice_number = @delivery.supplier_invoice_ref_number
      supplier_invoice_date = @delivery.supplier_invoice_date.to_s
      supplier_code = @repo.get_supplier_erp_number(@id)
      po_account_code = @repo.po_account_code_for_delivery(@id)

      costs = @repo.costs_for_delivery(@id)
      products = @repo.products_for_delivery(@id)
      del_totals = @replenish_repo.del_sub_totals(@id, delimiter: '', no_decimals: 5)

      request_xml = Nokogiri::XML::Builder.new do |xml| # rubocop:disable Metrics/BlockLength
        xml.purchase_invoice do # rubocop:disable Metrics/BlockLength
          xml.supplier_invoice_number supplier_invoice_number
          xml.supplier_invoice_date supplier_invoice_date.to_s
          xml.internal_invoice_number delivery_number
          xml.supplier_code supplier_code
          xml.account_code po_account_code
          xml.invoice_total del_totals[:total]
          xml.subtotal del_totals[:subtotal]
          xml.vat del_totals[:vat]
          xml.costs do
            costs.each do |cost|
              xml.cost do
                xml.cost_code cost[:cost_type_code]
                xml.account_code cost[:account_code]
                xml.amount UtilityFunctions.delimited_number(cost[:amount], delimiter: '', no_decimals: 2)
                xml.object 'OTH'
              end
            end
          end
          xml.line_items do
            products.each do |line_item|
              xml.line_item do
                xml.product_number line_item[:product_number]
                xml.product_description line_item[:product_description]
                xml.unit_price UtilityFunctions.delimited_number(line_item[:unit_price], delimiter: '', no_decimals: 5)
                xml.quantity UtilityFunctions.delimited_number(line_item[:quantity], delimiter: '', no_decimals: 2)
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
      res.success ? res : (raise Crossbeams::InfoError, res.message)
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

    def apply_delivery_changes(formatted_res)
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

    def apply_grn_changes(formatted_res)
      @repo.transaction do
        if formatted_res.success
          @dispatch_repo.grn_complete_invoice(@grn_id, formatted_res.instance)
          @repo.log_status('mr_goods_returned_notes', @grn_id, 'PURCHASE INVOICE COMPLETED', user_name: @user_name)
        else
          @dispatch_repo.update_mr_goods_returned_note(@grn_id, invoice_error: true)
          @repo.log_status('mr_goods_returned_notes', @grn_id, formatted_res.message, user_name: @user_name)
        end
        @block&.call
      end
    end
  end
end
