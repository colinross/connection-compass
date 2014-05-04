require_relative '../base'

module Services
  class Twitter < Base
    def initialize(access_token)
      conn_options = {
        url: "https://api.twitter.com/1.1",  
        params:  {access_token: access_token},
      }
      super(conn_options)
    end

    private
    def validate_access_token!(access_token)
      @user_info = conn.get '/account/verify_credentials.json'
    end
  end
end
