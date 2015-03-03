module ZanoxRuby
  # @attr [Integer] id              The profileItem's identifer from Zanox
  # @attr [Fixnum]  adrank          The adrank
  # @attr [String]  first_name      The first name of the profile holder
  # @attr [String]  last_name       The last name of the profile holder
  # @attr [String]  email           The email address of the profile
  # @attr [String]  country         The country of the profile
  # @attr [String]  street1         The first adress line
  # @attr [String]  city            The city of the profile
  # @attr [String]  zipcode         The zip code of the profile
  # @attr [String]  login_name      The login name of the profile
  # @attr [String]  user_name       The user name of the profile
  # @attr [String]  title           The title of the profile holder
  # @attr [String]  currency        The currency of the account
  # @attr [String]  language        The language setting of the account
  # @attr [String]  fax             The fax number of the profile holder
  # @attr [String]  mobile          The mobile number of the profile holder
  # @attr [String]  phone           The phone number of the profile holder
  # @attr [String]  street2         The second adress line
  # @attr [String]  company         The company to which the profile belongs
  # @attr [Boolean] is_advertiser   The account is an advertiser account
  # @attr [Boolean] is_sublogin     The account is a sublogin of a main account
  class Profile
    RESOURCE_PATH = '/profiles'

    class << self
      # Get all profiles associated to the connect ID.
      #
      # This is equivalent to the Zanox API method getProfiles.
      #
      # @return [Array<Profile>]
      #
      # @example
      #           profiles = ZanoxRuby::Profile.all #=> [#<Profile ...>]
      #           profile  = profiles.first #=> #<Profile ...>
      def all
        response = self.connection.signature_get()
        data = response.parsed_response.fetch('profileItem')
        profiles = []

        data.each do |profile|
          profiles << self.new(profile)
        end

        profiles
      end

      # Get the first profiles' information.
      #
      # This gives convenient access to your main profile,
      # as often the Zanox API getProfiles method will only return
      # one profileItem.
      #
      # @return [Profile]
      #
      # @example
      #           my_profile = ZanoxRuby::Profile.first #=> #<Profile ...>
      def first
        Profile.all.first
      end

      # The connection instance with relative_path for Profile
      #
      # @return [Connection]
      def connection
        @connection ||= ZanoxRuby::Connection.new(RESOURCE_PATH)
      end
    end

    # Profile information
    #
    # Resource Information
    # Rate Limited?     No
    # Authentication    Requires signature.
    # Response Formats  json, xml
    # HTTP Methods      GET, PUT
    # Resource family   Profile
    # Response Object   profileItem
    # API Version       2011-03-01
    #
    # GET {https://developer.zanox.com/web/guest/publisher-api-2011/get-profiles}
    # PUT {https://developer.zanox.com/web/guest/publisher-api-2011/put-profiles}
    #
    def initialize(data = {})
      @id = data.fetch('@id').to_i
      @adrank = data.fetch('adrank')
      @firstName = data.fetch('firstName')
      @lastName = data.fetch('lastName')
      @email = data.fetch('email')
      @country = data.fetch('country')
      @street1 = data.fetch('street1')
      @city = data.fetch('city')
      @zipcode = data.fetch('zipcode')
      @loginName = data.fetch('loginName')
      @userName = data.fetch('userName')
      @isAdvertiser = data.fetch('isAdvertiser')
      @isSublogin = data.fetch('isSublogin')
      # Optional returned data
      @title = data.fetch('title', nil)
      @currency = data.fetch('currency', nil)
      @language = data.fetch('language', nil)
      @fax = data.fetch('fax', nil)
      @mobile = data.fetch('mobile', nil)
      @phone = data.fetch('phone', nil)
      @street2 = data.fetch('street2', nil)
      @company = data.fetch('company', nil)
    end

    attr_accessor :id, :adrank, :first_name, :last_name, :email, :country, :street1, :city,
      :zipcode, :login_name, :user_name, :is_advertiser, :is_sublogin,
      :title, :currency, :language, :fax, :mobile, :phone, :street2, :company

    # make API names available
    alias firstName first_name
    alias lastName last_name
    alias loginName login_name
    alias userName user_name
    alias isAdvertiser is_advertiser
    alias isSublogin is_sublogin
  end
end
