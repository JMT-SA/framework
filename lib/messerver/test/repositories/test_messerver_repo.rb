# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MesserverApp
  class TestMesserverRepo < MiniTestWithHooks
    def standard_http_fails
      [
        { method_return: failed_response('The destination server encountered an error. The response code is 500', response_code: '500'), instance: { response_code: '500' }, msg: 'The destination server encountered an error. The response code is 500' },
        { method_return: failed_response('The request was not successful. The response code is 444', response_code: '444'), instance: { response_code: '444' }, msg: 'The request was not successful. The response code is 444' },
        { method_return: failed_response('The call to the server timed out.', timeout: true), instance: { timeout: true }, msg: 'The call to the server timed out.' },
        { method_return: failed_response('The connection was refused. Perhaps the server is not running.', refused: true), instance: { refused: true }, msg: 'The connection was refused. Perhaps the server is not running.' },
        { method_return: failed_response('There was an error: RuntimeError: Horrible Test,'), instance: {}, msg: 'There was an error: RuntimeError: Horrible Test,' }
      ]
    end

    def test_printer_list
      pl = { 'PrinterList' => %w[PRN-01 PRN-02] }
      MesserverRepo.any_instance.stubs(:request_uri).returns(success_response('ok', OpenStruct.new(body: pl.to_yaml, response_code: '200')))
      res = repo.printer_list
      assert res.success
      assert_equal 'Refreshed printers', res.message
      assert_equal pl['PrinterList'], res.instance

      standard_http_fails.each do |rule|
        MesserverRepo.any_instance.stubs(:request_uri).returns(rule[:method_return])
        res = repo.printer_list
        refute res.success
        assert_equal rule[:msg], res.message
        assert_equal rule[:instance], res.instance
      end
    end

    def test_publish_target_list
      pl = { 'PublishServerList' => %w[Server-01 Server-02] }
      MesserverRepo.any_instance.stubs(:request_uri).returns(success_response('ok', OpenStruct.new(body: pl.to_yaml, response_code: '200')))
      res = repo.publish_target_list
      assert res.success
      assert_equal 'Target destinations', res.message
      assert_equal pl['PublishServerList'], res.instance

      standard_http_fails.each do |rule|
        MesserverRepo.any_instance.stubs(:request_uri).returns(rule[:method_return])
        res = repo.publish_target_list
        refute res.success
        assert_equal rule[:msg], res.message
        assert_equal rule[:instance], res.instance
      end
    end

    def test_send_publish_package
      MesserverRepo.any_instance.stubs(:post_package).returns(success_response('ok', OpenStruct.new(body: 'BODY', response_code: '200')))
      res = repo.send_publish_package('Zebra', %w[t1 t2], 'a/path/to/file', 'BINDATA')
      assert res.success
      assert_equal 'ok', res.message
      assert_equal 'BODY', res.instance

      standard_http_fails.each do |rule|
        MesserverRepo.any_instance.stubs(:post_package).returns(rule[:method_return])
        res = repo.send_publish_package('Zebra', %w[t1 t2], 'a/path/to/file', 'BINDATA')
        refute res.success
        assert_equal rule[:msg], res.message
        assert_equal rule[:instance], res.instance
      end
    end

    def test_send_publish_status
      pl = { 'Data' => %w[Server-01-OK Server-02-OK] }
      MesserverRepo.any_instance.stubs(:request_uri).returns(success_response('ok', OpenStruct.new(body: pl.to_yaml, response_code: '200')))
      res = repo.send_publish_status('Zebra', 'a/path/to/file')
      assert res.success
      assert_equal 'Status', res.message
      assert_equal pl['Data'], res.instance

      standard_http_fails.each do |rule|
        MesserverRepo.any_instance.stubs(:request_uri).returns(rule[:method_return])
        res = repo.send_publish_status('Zebra', 'a/path/to/file')
        refute res.success
        assert_equal rule[:msg], res.message
        assert_equal rule[:instance], res.instance
      end
    end

    def test_label_variables
      xml = '<dummy><var name="F1">A variable</var></dummy>'
      MesserverRepo.any_instance.stubs(:request_uri).returns(success_response('ok', OpenStruct.new(body: xml, response_code: '200')))
      res = repo.label_variables('Zebra', 'a/path/to/file')
      assert res.success
      assert_equal 'Label XML', res.message
      assert_equal xml, res.instance

      standard_http_fails.each do |rule|
        MesserverRepo.any_instance.stubs(:request_uri).returns(rule[:method_return])
        res = repo.label_variables('Zebra', 'a/path/to/file')
        refute res.success
        assert_equal rule[:msg], res.message
        assert_equal rule[:instance], res.instance
      end
    end

    def preview_label
      MesserverRepo.any_instance.stubs(:post_binary).returns(success_response('ok', OpenStruct.new(body: 'BODY', response_code: '200')))
      res = repo.send_publish_package('screen', %w[v1 v2], 'label_one', 'BINDATA')
      assert res.success
      assert_equal 'ok', res.message
      assert_equal 'BODY', res.instance

      standard_http_fails.each do |rule|
        MesserverRepo.any_instance.stubs(:post_binary).returns(rule[:method_return])
        res = repo.send_publish_package('screen', %w[v1 v2], 'label_one', 'BINDATA')
        refute res.success
        assert_equal rule[:msg], res.message
        assert_equal rule[:instance], res.instance
      end
    end

    def test_print_published_label
      fails = [
        { method_return: failed_response('ok', response_code: '404'), instance: {}, msg: 'The label was not found. Has it been published yet?' },
        { method_return: failed_response('No printer', response_code: '503'), instance: { response_code: '503' }, msg: 'No printer' }
      ]

      (fails + standard_http_fails).each do |rule|
        MesserverRepo.any_instance.stubs(:post_print_or_preview).returns(rule[:method_return])
        res = repo.print_published_label('name', [], 2, 'PRN-01')
        refute res.success
        assert_equal rule[:msg], res.message
        assert_equal rule[:instance], res.instance
      end

      MesserverRepo.any_instance.stubs(:post_print_or_preview).returns(success_response('ok', OpenStruct.new(body: 'SOMETHING', response_code: '200')))
      res = repo.print_published_label('name', [], 2, 'PRN-01')
      assert res.success
      assert_equal 'Printed label', res.message
      assert_equal 'SOMETHING', res.instance
    end

    private

    def repo
      MesserverRepo.new
    end
  end
end
