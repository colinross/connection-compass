require 'forwardable'
require 'moneta'
require 'faraday/http_cache'

# Have to freedom patch Moneta to match the ruby store convention of using read and write
module Moneta
  module Defaults
    alias :read :[]
    alias :write :[]=
  end
end

# This class is not meant to be used directly, use the specific
# service's implimentation instead, such as Services::Facebook
module Services
  class Base
    extend Forwardable

    attr_reader :conn

    def initialize(options = {})
      url = options.fetch(:url, nil)
      raise '`url` must be set.' if url.empty?
      options = options.keep_if{|key,value| allowed_faraday_options.include?(key) && !value.nil? }
      @conn ||= ::Faraday.new(options) do |faraday|
        faraday.request  :url_encoded  # form-encode POST params
        faraday.response :logger
        faraday.response :json, :content_type => /\bjson$/
        faraday.adapter  Faraday.default_adapter
        faraday.use Faraday::Response::RaiseError # http://stackoverflow.com/questions/20844679/looking-for-example-of-faraday-middleware-with-error-checking
        faraday.use Faraday::HttpCache, store: Moneta.new(:DataMapper, setup: ConnectionCompass::DATABASE_URL)
        faraday.use VCR::Middleware::Faraday if ENV['env'] == "test"
      end
    end

    ::Faraday::Connection::METHODS.to_a.each do |method|
      define_method(method) do |url| 
        begin
          conn.send(method.to_sym,url)
        rescue Faraday::Error::ClientError => e
          self.handle_error_response JSON.parse(e.response[:body])
        end
      end 
    end

    # For testing with mocks, just pass in a MiniTest::Mock
    def override_conn!(conn)
      @conn = conn
    end

    protected

    # The list of allowed configuration options to pass to the Faraday
    # client.
    def allowed_faraday_options
      [:url,:params, :headers, :ssl]
    end
  end
end
