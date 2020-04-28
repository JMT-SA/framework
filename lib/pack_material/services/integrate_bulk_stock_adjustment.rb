# frozen_string_literal: true

module PackMaterialApp
  class IntegrateBulkStockAdjustment < BaseService
    # Send XML representation to accounting system.
    # - use the `just_show_xml` flag to check the XML output without modifying the db.
    #
    # @param user_name [string] the user who initiated this task.
    # @param [Integer] mr_bulk_stock_adjustment_id
    # @param just_show_xml [bool] set to true to just return XML from the call without updating the db.
    def initialize(mr_bulk_stock_adjustment_id, user_name, just_show_xml = false, block = nil)
      @block = block
      @repo = TransactionsRepo.new
      @bsa_repo = BulkStockAdjustmentRepo.new
      @log_repo = DevelopmentApp::LoggingRepo.new
      @user_name = user_name
      @id = mr_bulk_stock_adjustment_id
      @just_show_xml = just_show_xml
      @bsa = @repo.find_mr_bulk_stock_adjustment(@id)
      @time = DateTime.now
    end

    def call
      return failed_response('Bulk Stock Adjustment does not exist') unless @bsa

      request_xml = build_xml
      return request_xml if @just_show_xml

      log_string = '_so_xml'
      @log_repo.log_infodump('integrate_bsa', @id, 'sending' + log_string, request_xml)

      res = make_http_call(request_xml)
      @log_repo.log_infodump('integrate_bsa', @id, 'response' + log_string, res.instance.body)

      formatted_res = format_response(res.instance.body)
      apply_changes(formatted_res)
    end

    private

    def build_xml # rubocop:disable Metrics/AbcSize
      total_depreciation_value = @bsa_repo.depreciation_value(@id)
      depreciation_value = UtilityFunctions.delimited_number(total_depreciation_value, delimiter: '', no_decimals: 2)

      request_xml = Nokogiri::XML::Builder.new do |xml|
        xml.bsa_journal do
          xml.transaction_date @time
          xml.reference 'JVL'
          xml.description "Correction of PMAT Stock - BSA #{@bsa.stock_adjustment_number}"
          xml.items do
            xml.item do
              xml.account '10650' # '77300' #10650
              xml.object 'PGM' # 'OTH'
              xml.description "Correction of PMAT Stock - BSA #{@bsa.stock_adjustment_number}"
              xml.base_debit depreciation_value
              xml.base_credit nil
            end
            xml.item do
              xml.account '77000'
              xml.object 'OTH'
              xml.description "Correction of PMAT Stock - BSA #{@bsa.stock_adjustment_number}"
              xml.base_debit nil
              xml.base_credit depreciation_value
            end
          end
        end
      end
      request_xml.to_xml
    end

    def make_http_call(xml)
      http = Crossbeams::HTTPCalls.new
      res  = http.xml_post(AppConst::ERP_BSA_JOURNAL_URI, xml)
      res.success ? res : (raise Crossbeams::InfoError, res.message)
    end

    def format_response(response)
      resp = Nokogiri::XML(response)
      message = resp.xpath('//error').text
      instance = {
        journal_number: resp.xpath('//journal_number').text,
        time: @time
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
          @bsa_repo.bsa_integration(@id, formatted_res.instance)
          @repo.log_status('mr_bulk_stock_adjustments', @id, 'BSA INTEGRATED', user_name: @user_name)
        else
          @repo.update_mr_bulk_stock_adjustment(@id, integration_error: true)
          @repo.log_status('mr_bulk_stock_adjustments', @id, formatted_res.message, user_name: @user_name)
        end
        @block&.call
      end
    end
  end
end
