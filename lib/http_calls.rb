# frozen_string_literal: true

# A class for making HTTP calls
module Crossbeams
  class HTTPCalls
    include Crossbeams::Responses

    def json_post(url, params)
      uri, http = setup_http(url)
      request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
      request.body = params.to_json

      log_request(request)

      response = http.request(request)
      format_response(response)
    rescue Timeout::Error
      failed_response('The call to the server timed out.', timeout: true)
    rescue Errno::ECONNREFUSED
      failed_response('The connection was refused. Perhaps the server is not running.', refused: true)
    rescue StandardError => e
      failed_response("There was an error: #{e.message}")
    end

    def xml_post(url, xml)
      uri, http = setup_http(url)
      request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/xml')
      request.body = xml

      log_request(request)

      response = http.request(request)
      format_response(response)
    rescue Timeout::Error
      failed_response('The call to the server timed out.', timeout: true)
    rescue Errno::ECONNREFUSED
      failed_response('The connection was refused. Perhaps the server is not running.', refused: true)
    rescue StandardError => e
      failed_response("There was an error: #{e.message}")
    end

    private

    def setup_http(url)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)

      http.open_timeout = 5
      http.read_timeout = 10

      [uri, http]
    end

    def format_response(response)
      if response.code == '200'
        success_response(response.code, response)
      else
        msg = response.code.start_with?('5') ? 'The destination server encountered an error.' : 'The request was not successful.'
        failed_response("#{msg} The response code is #{response.code}", response.code)
      end
    end

    def log_request(request)
      if request.method == 'GET'
        puts ">>> HTTP call: #{request.method} >> #{request.path}"
      else
        body = ENV['LOGFULLMESSERVERCALLS'] ? request.body : request.body[0, 300]
        puts ">>> HTTP call: #{request.method} >> #{request.path} > #{body}"
      end
    end
  end
end
