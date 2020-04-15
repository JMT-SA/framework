# frozen_string_literal: true

module PackMaterialApp
  class CompleteSalesOrder < BaseService # rubocop:disable Metrics/ClassLength
    # Complete a sales order and send XML representation to accounting system.
    # - use the `just_show_xml` flag to check the XML output without modifying the db.
    #
    # @param user_name [string] the user who initiated this task.
    # @param [Integer] mr_sales_order_id
    # @param just_show_xml [bool] set to true to just return XML from the call without updating the db.
    def initialize(mr_sales_order_id, user_name, just_show_xml = false, block = nil)
      @block = block
      @repo  = DispatchRepo.new
      @log_repo = DevelopmentApp::LoggingRepo.new
      @user_name = user_name
      @id = mr_sales_order_id
      @just_show_xml = just_show_xml
      @sales_order = @repo.find_mr_sales_order(@id)
    end

    def call
      return failed_response('Sales Order does not exist') unless @sales_order

      request_xml = build_xml
      return request_xml if @just_show_xml

      log_string = '_so_xml'
      @log_repo.log_infodump('complete_sales_order', @id, 'sending' + log_string, request_xml)

      res = make_http_call(request_xml)
      @log_repo.log_infodump('complete_sales_order', @id, 'response' + log_string, res.instance.body)

      formatted_res = format_response(res.instance.body)
      apply_changes(formatted_res)
    end

    private

    def build_xml # rubocop:disable Metrics/AbcSize
      products = @repo.products_for_sales_order(@id)
      so_totals = @repo.so_sub_totals(@id, delimiter: '', no_decimals: 5)
      costs = @repo.so_costs(@id)
      total_cost_of_sales = products.sum { |r| r[:weighted_average_cost] * r[:quantity_required] }
      cost_of_sales = UtilityFunctions.delimited_number(total_cost_of_sales, delimiter: '', no_decimals: 2)

      request_xml = Nokogiri::XML::Builder.new do |xml| # rubocop:disable Metrics/BlockLength
        xml.sales_invoice do # rubocop:disable Metrics/BlockLength
          xml.internal_invoice_number @sales_order.sales_order_number
          xml.customer_code @sales_order.erp_customer_number
          xml.account_code @sales_order.account_code
          xml.shipped_at @sales_order.shipped_at
          xml.invoice_total so_totals[:total]
          xml.subtotal so_totals[:subtotal]
          xml.vat so_totals[:vat]
          xml.object 'PGM'
          xml.costs do
            costs.each do |cost|
              xml.cost do
                xml.item 'NS100107'
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
                xml.item 'NS100120'
                xml.description line_item[:product_variant_code]
                xml.unit_price UtilityFunctions.delimited_number(line_item[:unit_price], delimiter: '', no_decimals: 5)
                xml.quantity UtilityFunctions.delimited_number(line_item[:quantity_required], delimiter: '', no_decimals: 2)
                xml.line_total UtilityFunctions.delimited_number(line_item[:line_total], delimiter: '', no_decimals: 2)
                xml.cost UtilityFunctions.delimited_number(line_item[:weighted_average_cost], delimiter: '', no_decimals: 5)
                xml.fifo UtilityFunctions.delimited_number(line_item[:weighted_average_cost], delimiter: '', no_decimals: 5)
                xml.location 'PMAT'
              end
            end
          end
          xml.profit_loss_journal do
            xml.transaction_date @sales_order.shipped_at
            xml.reference 'MBB'
            xml.items do
              xml.item do
                xml.account '10650'
                xml.object 'PGM, PML, PPM, FUT'
                xml.description 'Profit/Loss on Packing Material'
                xml.base_debit cost_of_sales
                xml.base_credit nil
              end
              xml.item do
                xml.account '77000'
                xml.object nil
                xml.description 'Inventory'
                xml.base_debit nil
                xml.base_credit cost_of_sales
              end
            end
            xml.total_base_debit
            xml.total_base_credit
          end
        end
      end
      request_xml.to_xml
    end

    def make_http_call(xml)
      http = Crossbeams::HTTPCalls.new
      res  = http.xml_post(AppConst::ERP_SALES_INVOICE_URI, xml)
      res.success ? res : (raise Crossbeams::InfoError, res.message)
    end

    def format_response(response)
      resp = Nokogiri::XML(response)
      message = resp.xpath('//invoice_error').text
      message ||= resp.xpath('//error').text
      instance = {
        sales_invoice_number: resp.xpath('//sales_invoice_number').text,
        journal_number: resp.xpath('//journal_number').text
      }
      if message.empty?
        success_response('ok', instance)
      else
        failed_response(message, instance)
      end
    end

    def apply_changes(formatted_res)
      @repo.transaction do
        if formatted_res.success
          @repo.so_complete_invoice(@id, formatted_res.instance)
          @repo.log_status('mr_sales_orders', @id, 'SALES ORDER COMPLETED', user_name: @user_name)
        else
          @repo.update_mr_sales_order(@id, integration_error: true)
          @repo.log_status('mr_sales_orders', @id, formatted_res.message, user_name: @user_name)
        end
        @block&.call
      end
    end
  end
end
