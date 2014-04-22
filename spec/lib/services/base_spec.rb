require_relative '../../spec_helper'
require_relative '../../../lib/services/base'

describe Services::Base do
  it "should accept faraday options (url, params, headers) in the initialize method, including blocks" do
    options = {url: "http://some-service-domain.tld/",
             params: {"some_param" => "some_params_value"},
             headers: {"some_header" => "some_header_value"}
        }
    @instance = Services::Base.new(options)
    @instance.wont_be_nil
    @instance.conn.url_prefix.to_s.must_equal options[:url]
    @instance.conn.params.must_equal options[:params]
    @instance.conn.headers.must_be :include_hash?, options[:headers]

  end
  describe "Instances" do
    before do
      options = {url: "http://some-service-domain.tld/",
              params: {"some_param" => "some_params_value"},
              headers: {"some_header" => "some_header_value"}
        }
      @instance = Services::Base.new(options)
    end
    it "should forward connection method helper methods to the connected faraday client" do
      @mock_conn = MiniTest::Mock.new
      ::Faraday::Connection::METHODS.to_a.each do |method|
        @mock_conn.expect method.to_sym, '#lolhipster #{method.to_s}', [String]
      end
      @instance.override_conn!(@mock_conn)

      (::Faraday::Connection::METHODS.to_a - [:get]).each do |method|
        @response = @instance.send(method, 'test.json')
        @response.wont_be_nil
        @response.must_include '#lolhipster #{method.to_s}'
      end

      # also supports passing blocks
      @response = @instance.get 'test.json' do |req|
        req.headers[:content_type] = 'application/json'
      end

      assert @mock_conn.verify
    end
  end
end

