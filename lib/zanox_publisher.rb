require 'zanox_publisher/version'

module ZanoxPublisher
  autoload :Connection,         'zanox_publisher/connection'
  autoload :Base,               'zanox_publisher/base'
  autoload :Category,           'zanox_publisher/category'
  autoload :Format,             'zanox_publisher/format'
  autoload :Vertical,           'zanox_publisher/vertical'
  autoload :Policy,             'zanox_publisher/policy'
  autoload :Prize,              'zanox_publisher/prize'
  autoload :TrackingLink,       'zanox_publisher/tracking_link'
  autoload :Profile,            'zanox_publisher/profile'
  autoload :AdSpace,            'zanox_publisher/ad_space'
  autoload :AdMedium,           'zanox_publisher/ad_medium'
  autoload :Product,            'zanox_publisher/product'
  autoload :Program,            'zanox_publisher/program'
  autoload :ProgramApplication, 'zanox_publisher/program_application'
  autoload :IncentiveBase,      'zanox_publisher/incentive_base'
  autoload :Incentive,          'zanox_publisher/incentive'
  autoload :ExclusiveIncentive, 'zanox_publisher/exclusive_incentive'

  class << self
    attr_accessor :connect_id, :secret_key

    # Setup connect ID and secret key for ZanoxPublisher.
    # The connect ID and secret key will be used for all subsequent requests.
    #
    # @param connect_id [String] The connect ID of your account for authentication
    # @param secret_key [String] The secret key of your account for authentication
    #
    # @example
    #           ZanoxPublisher::authenticate("<your_client_id>", "<your_client_secret>")
    #           ZanoxPublisher::Profile.first #=> <Profile>
    #
    def authenticate(connect_id, secret_key)
      @connect_id, @secret_key = connect_id, secret_key
    end
  end
end
