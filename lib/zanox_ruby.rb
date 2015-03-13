require 'zanox_ruby/version'

module ZanoxRuby
  autoload :Connection,         'zanox_ruby/connection'
  autoload :Base,               'zanox_ruby/base'
  autoload :Category,           'zanox_ruby/category'
  autoload :Format,             'zanox_ruby/format'
  autoload :TrackingLink,       'zanox_ruby/tracking_link'
  autoload :Profile,            'zanox_ruby/profile'
  autoload :AdSpace,            'zanox_ruby/ad_space'
  autoload :AdMedium,           'zanox_ruby/ad_medium'
  autoload :Product,            'zanox_ruby/product'
  autoload :Program,            'zanox_ruby/program'
  autoload :Incentive,          'zanox_ruby/incentive'

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
