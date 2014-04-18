module Services
  class Base
    attr_reader :url, :params, :headers
    attr_reader :conn

    def initialize(options = {})
      @url = options.fetch(:url, nil)
      raise '`url` must be set.' unless url.present?

      @params = options.fetch(:params, nil)
      @headers = options.fetch(:headers, nil)
      @conn ||= Faraday.new(:url => url) do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
        faraday.params params if params.present?
        faraday.headers headers if headers.present?
      end
    end
  end
end