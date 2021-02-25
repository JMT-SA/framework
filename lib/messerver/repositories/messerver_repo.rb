# frozen_string_literal: true

module MesserverApp
  class MesserverRepo # rubocop:disable Metrics/ClassLength
    include Crossbeams::Responses

    def printer_list
      res = request_uri(printer_list_uri)
      return res unless res.success

      begin
        printer_list = YAML.safe_load(res.instance.body)
      rescue Psych::Error => e
        ErrorMailer.send_exception_email(e, subject: "#{self.class.name}#printer_list", message: "YAML string from MesServer is #{res.instance.body}")
        return failed_response('There was an error in the response from MesServer')
      end
      success_response('Refreshed printers', printer_list['PrinterList'])
    end

    def mes_module_list
      res = request_uri(module_list_uri)
      return res unless res.success

      begin
        module_list = YAML.safe_load(res.instance.body)
      rescue Psych::Error => e
        ErrorMailer.send_exception_email(e, subject: "#{self.class.name}#module_list", message: "YAML string from MesServer is #{res.instance.body}")
        return failed_response('There was an error in the response from MesServer')
      end
      success_response('Refreshed modules', module_list['ModuleList'])
    end

    def publish_target_list
      res = request_uri(publish_target_list_uri)
      return res unless res.success

      begin
        yaml_list = YAML.safe_load(res.instance.body)
      rescue Psych::Error => e
        ErrorMailer.send_exception_email(e, subject: "#{self.class.name}#publish_target_list", message: "YAML string from MesServer is #{res.instance.body}")
        return failed_response('There was an error in the response from MesServer')
      end
      success_response('Target destinations', yaml_list['PublishServerList'])
    end

    def send_publish_package(printer_type, targets, fname, binary_data)
      res = post_package(publish_send_uri, printer_type, targets, fname, binary_data)
      return res unless res.success

      success_response('ok', res.instance.body)
    end

    def send_publish_status(printer_type, filename)
      res = request_uri(publish_status_uri(printer_type, filename))
      return res unless res.success

      begin
        yaml_list = YAML.safe_load(res.instance.body)
      rescue Psych::Error => e
        ErrorMailer.send_exception_email(e, subject: "#{self.class.name}#send_publish_status", message: "YAML string from MesServer is #{res.instance.body}")
        return failed_response('There was an error in the response from MesServer')
      end
      # p yaml_list
      success_response('Status', yaml_list['Data'])
    end

    def label_variables(printer_type, filename)
      res = request_uri(label_variables_uri(printer_type, filename))
      return res unless res.success

      success_response('Label XML', res.instance.body)
    end

    def preview_label(screen_or_print, vars, fname, binary_data)
      res = post_binary(preview_uri, vars, screen_or_print, fname, binary_data)
      return res unless res.success

      success_response('ok', res.instance.body)
    end

    def print_published_label(label_template_name, vars, quantity, printer, host = nil)
      res = post_print_or_preview(print_published_label_uri(host), label_template_name, vars, quantity: quantity, printer: printer)
      unless res.success
        res = if res.instance[:response_code].to_s == '404'
                failed_response('The label was not found. Has it been published yet?')
              else
                res
              end
        return res
      end
      success_response('Printed label', res.instance.body)
    end

    def preview_published_label(label_template_name, vars, printer_type = AppConst::PREVIEW_PRINTER_TYPE)
      res = post_print_or_preview(preview_published_label_uri, label_template_name, vars, printer_type: printer_type)
      unless res.success
        res = if res.instance[:response_code].to_s == '404'
                failed_response('The label was not found. Has it been published yet?')
              else
                res
              end
        return res
      end
      success_response('Preview label', res.instance.body)
    end

    def bulk_registration_mode(mes_module, start = true)
      request_uri(bulk_registration_mode_uri(mes_module, start))
    end

    private

    def publish_part_of_body(printer_type, targets)
      post_body = []
      post_body << "--#{AppConst::POST_FORM_BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data; name=\"printertype\"\r\n"
      post_body << "\r\n#{printer_type}"
      post_body << "\r\n--#{AppConst::POST_FORM_BOUNDARY}--\r\n"
      post_body << "--#{AppConst::POST_FORM_BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data; name=\"publishlist\"\r\n"
      post_body << "\r\n#{targets.join(',')}"
      post_body << "\r\n--#{AppConst::POST_FORM_BOUNDARY}--\r\n"
      post_body
    end

    def print_part_of_body(vars)
      post_body = []
      post_body << "--#{AppConst::POST_FORM_BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data; name=\"action\"\r\n"
      post_body << "\r\nprintlabel"
      post_body << "\r\n--#{AppConst::POST_FORM_BOUNDARY}--\r\n"
      post_body << "--#{AppConst::POST_FORM_BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data; name=\"printername\"\r\n"
      post_body << "\r\n#{vars[:printer]}"
      post_body << "\r\n--#{AppConst::POST_FORM_BOUNDARY}--\r\n"
      post_body
    end

    def shared_part_of_body(fname, binary_data, unitfolder: 'ldesign')
      post_body = []
      post_body << "--#{AppConst::POST_FORM_BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data; name=\"unitfolder\"\r\n"
      post_body << "\r\n#{unitfolder}"
      post_body << "\r\n--#{AppConst::POST_FORM_BOUNDARY}--\r\n"
      post_body << "--#{AppConst::POST_FORM_BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data; name=\"datafile\"; filename=\"#{fname}.zip\"\r\n"
      post_body << "Content-Type: application/x-zip-compressed\r\n"
      post_body << "\r\n"
      post_body << binary_data
      post_body << "\r\n--#{AppConst::POST_FORM_BOUNDARY}--\r\n"
      post_body
    end

    def post_binary(uri, vars, screen_or_print, fname, binary_data) # rubocop:disable Metrics/AbcSize
      post_body = screen_or_print == 'print' ? print_part_of_body(vars) : []
      post_body += shared_part_of_body(fname, binary_data)

      http = Net::HTTP.new(uri.host, uri.port)
      http.open_timeout = 5
      http.read_timeout = 10
      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = post_body.join
      request['Content-Type'] = "multipart/form-data, boundary=#{AppConst::POST_FORM_BOUNDARY}"
      log_request(request)

      response = http.request(request)
      format_response(response, "#{uri}\nName: #{fname}\n(post_binary)")
    rescue Timeout::Error
      failed_response('The call to the server timed out.', timeout: true)
    rescue Errno::ECONNREFUSED
      failed_response('The connection was refused. Perhaps the server is not running.', refused: true)
    rescue StandardError => e
      ErrorMailer.send_exception_email(e, subject: self.class.name, message: "URI is #{uri}\nScreen or print is #{screen_or_print}\nFname: #{fname}\nVars: #{vars.inspect}")
      failed_response("There was an error: #{e.message}")
    end

    def post_package(uri, printer_type, targets, fname, binary_data) # rubocop:disable Metrics/AbcSize
      post_body = publish_part_of_body(printer_type, targets)
      post_body += shared_part_of_body(fname, binary_data, unitfolder: 'production')

      http = Net::HTTP.new(uri.host, uri.port)
      http.open_timeout = 5
      http.read_timeout = 10
      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = post_body.join
      request['Content-Type'] = "multipart/form-data, boundary=#{AppConst::POST_FORM_BOUNDARY}"
      log_request(request)

      response = http.request(request)
      format_response(response, "#{uri}\nName: #{fname}\n(post_package)")
    rescue Timeout::Error
      failed_response('The call to the server timed out.', timeout: true)
    rescue Errno::ECONNREFUSED
      failed_response('The connection was refused. Perhaps the server is not running.', refused: true)
    rescue StandardError => e
      ErrorMailer.send_exception_email(e, subject: self.class.name, message: "URI is #{uri}\nPrinter type is #{printer_type}\nTargets: #{targets.inspect}\nFname: #{fname}")
      failed_response("There was an error: #{e.message}")
    end

    def post_print_or_preview(uri, label_template_name, vars, options = {}) # rubocop:disable Metrics/AbcSize
      printer_type = options[:printer_type]
      quantity = options[:quantity]
      printer = options[:printer]
      # <ProductLabel PID="223" Status="true" Printer="PRN-23" LabelTemplateFile="KRM_Carton_Lbl_PL.nsld" Threading="true" RunNumber="2018_AP_18351_11_181A" Code="42DP42"  F0="E2" F1="01100217924066" F2="200004224184" F3="(GDL 10) Golden Delicious"
      post_body = []
      if printer
        post_body << "--#{AppConst::POST_FORM_BOUNDARY}\r\n"
        post_body << "Content-Disposition: form-data; name=\"printername\"\r\n"
        post_body << "\r\n#{printer}"
        post_body << "\r\n--#{AppConst::POST_FORM_BOUNDARY}--\r\n"
      end
      if printer_type
        post_body << "--#{AppConst::POST_FORM_BOUNDARY}\r\n"
        post_body << "Content-Disposition: form-data; name=\"printertype\"\r\n"
        post_body << "\r\n#{printer_type}"
        post_body << "\r\n--#{AppConst::POST_FORM_BOUNDARY}--\r\n"
      end
      post_body << "--#{AppConst::POST_FORM_BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data; name=\"labeltype\"\r\n"
      post_body << "\r\nnsld"
      post_body << "\r\n--#{AppConst::POST_FORM_BOUNDARY}--\r\n"
      post_body << "--#{AppConst::POST_FORM_BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data; name=\"labeltemplate\"\r\n"
      post_body << "\r\n#{label_template_name}"
      post_body << "\r\n--#{AppConst::POST_FORM_BOUNDARY}--\r\n"
      if printer
        post_body << "--#{AppConst::POST_FORM_BOUNDARY}\r\n"
        post_body << "Content-Disposition: form-data; name=\"quantity\"\r\n"
        post_body << "\r\n#{quantity}"
        post_body << "\r\n--#{AppConst::POST_FORM_BOUNDARY}--\r\n"
      end
      vars.each do |k, v|
        post_body << "--#{AppConst::POST_FORM_BOUNDARY}\r\n"
        post_body << "Content-Disposition: form-data; name=\"#{k}\"\r\n"
        post_body << "\r\n#{v}"
        post_body << "\r\n--#{AppConst::POST_FORM_BOUNDARY}--\r\n"
      end
      post_body << "Content-Disposition: form-data; name=\"eof\"\r\n"
      post_body << "\r\neof"
      post_body << "\r\n--#{AppConst::POST_FORM_BOUNDARY}--\r\n"

      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri)
      http.open_timeout = 5
      http.read_timeout = 10

      request.body = post_body.join
      request['Content-Type'] = "boundary=#{AppConst::POST_FORM_BOUNDARY}"
      log_request(request)

      response = http.request(request)
      format_response(response, "#{uri}\nLabel: #{label_template_name}\nVars: #{vars.inspect}\nOptions: #{options.inspect}\n(post_print_or_preview)")
    rescue Timeout::Error
      failed_response('The call to the server timed out.', timeout: true)
    rescue Errno::ECONNREFUSED
      failed_response('The connection was refused. Perhaps the server is not running.', refused: true)
    rescue StandardError => e
      ErrorMailer.send_exception_email(e, subject: self.class.name, message: "URI is #{uri}\nLabel is #{label_template_name}\nVars: #{vars.inspect}\nOptions: #{options.inspect}")
      failed_response("There was an error: #{e.message}")
    end

    def request_uri(uri) # rubocop:disable Metrics/AbcSize
      http = Net::HTTP.new(uri.host, uri.port)
      http.open_timeout = 5
      http.read_timeout = 10
      request = Net::HTTP::Get.new(uri.request_uri)
      log_request(request)
      response = http.request(request)

      format_response(response, "#{uri}\n(request_uri)")
    rescue Timeout::Error
      failed_response('The call to the server timed out.', timeout: true)
    rescue Errno::ECONNREFUSED
      failed_response('The connection was refused. Perhaps the server is not running.', refused: true)
    rescue StandardError => e
      ErrorMailer.send_exception_email(e, subject: self.class.name, message: "URI is #{uri}")
      failed_response("There was an error: #{e.message}")
    end

    def format_response(response, context = nil) # rubocop:disable Metrics/AbcSize
      if response.code == '200'
        if response.body&.include?('204 No content')
          send_error_email(response, context)
          failed_response('The server returned an empty response', response_code: '204')
        else
          success_response(response.code, response)
        end
      elsif response.code == '503' # The printer is unavailable
        failed_response(response.body, response_code: response.code)
      else
        msg = response.code.start_with?('5') ? 'The destination server encountered an error.' : 'The request was not successful.'
        send_error_email(response, context)
        failed_response("#{msg} The response code is #{response.code}", response_code: response.code)
      end
    end

    def send_error_email(response, context)
      body = []
      body << "The call to MesServer was:\n#{context}" unless context.nil?
      body << if response.body.nil?
                'Empty response body received'
              elsif response.body.encoding == Encoding::ASCII_8BIT
                'An image was probably returned from MesServer'
              else
                "The response from MesServer was:\n-------------------------------\n#{response.body}"
              end
      ErrorMailer.send_error_email(subject: "MesServer responded with error code #{response.code}",
                                   message: body.join("\n\n"))
    end

    def printer_list_uri
      URI.parse("#{AppConst::LABEL_SERVER_URI}?Type=GetPrinterList&ListType=yaml")
    end

    def module_list_uri(type = 'robot')
      URI.parse("#{AppConst::LABEL_SERVER_URI}?Type=GetModuleList&ListType=yaml#{type.nil? ? '' : "&ModuleType=#{type}"}")
    end

    def publish_target_list_uri
      URI.parse("#{AppConst::LABEL_SERVER_URI}?Type=GetPublishServerList&ListType=yaml")
    end

    def publish_send_uri
      URI.parse("#{AppConst::LABEL_SERVER_URI}LabelPublishFileUpload")
    end

    def publish_status_uri(printer_type, filename)
      URI.parse("#{AppConst::LABEL_SERVER_URI}?Type=GetPublishFileStatus&ListType=yaml&Name=#{filename}&PrinterType=#{printer_type}&Unit=production")
    end

    def label_variables_uri(printer_type, filename)
      URI.parse("#{AppConst::LABEL_SERVER_URI}?Type=GetLabelFileXml&unit=production&nsld=&printerType=#{printer_type}&File=#{filename}.xml")
    end

    def preview_uri
      URI.parse("#{AppConst::LABEL_SERVER_URI}LabelFileUpload")
    end

    def print_published_label_uri(host = nil)
      if host.nil?
        URI.parse("#{AppConst::LABEL_SERVER_URI}LabelPrint")
      else
        URI.parse("http://#{host}:2080/LabelPrint")
      end
    end

    def preview_published_label_uri
      URI.parse("#{AppConst::LABEL_SERVER_URI}LabelPreview")
    end

    def bulk_registration_mode_uri(mes_module, start = true)
      URI.parse("#{AppConst::LABEL_SERVER_URI}?Type=SetCardRegistrationState&Name=#{mes_module}&Status=#{start}")
    end

    def log_request(request)
      if request.method == 'GET'
        puts ">>> MesServer call: #{request.method} >> #{request.path}"
      else
        body = ENV['LOGFULLMESSERVERCALLS'] ? request.body : request.body[0, 300]
        puts ">>> MesServer call: #{request.method} >> #{request.path} > #{body}"
      end
    end
  end
end
