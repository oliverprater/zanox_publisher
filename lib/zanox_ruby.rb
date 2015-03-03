require 'zanox_ruby/version'

module ZanoxRuby
  autoload :Connection, 'zanox_ruby/connection'
  autoload :Profile,    'zanox_ruby/profile'

  class << self
    attr_accessor :connect_id, :secret_key

    # Setup connect ID and secret key for ZanoxRuby.
    # The connect ID and secret key will be used for all subsequent requests.
    #
    # @param connect_id [String] The connect ID of your account for authentication
    # @param secret_key [String] The secret key of your account for authentication
    #
    # @example
    #           ZanoxRuby::authenticate("<your_client_id>", "<your_client_secret>")
    #           connection = ZanoxRuby::Connection.new
    #           connection.get('/profile') # => JSON Response
    #
    def authenticate(connect_id, secret_key)
      @connect_id, @secret_key = connect_id, secret_key
    end
  end
end
