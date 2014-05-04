require 'forwardable'

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
    def_delegators :conn, *::Faraday::Connection::METHODS.to_a

    attr_reader :conn

    def initialize(options = {})
      url = options.fetch(:url, nil)
      raise '`url` must be set.' if url.empty?
      options = options.keep_if{|key,value| allowed_faraday_options.include?(key) && !value.nil? }
      @conn ||= ::Faraday.new(options) do |faraday|
        faraday.request  :url_encoded  # form-encode POST params
        faraday.response :logger
        faraday.adapter  Faraday.default_adapter
        faraday.use Faraday::HttpCache, store: Moneta.new(:DataMapper, setup: ConnectionCompass::DATABASE_URL)
        faraday.use VCR::Middleware::Faraday if ENV['env'] == "test"
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
