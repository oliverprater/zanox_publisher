module ZanoxPublisher
  # AdSpaces
  #
  # Access and modify your AdSpace information
  #
  # @attr [Integer]         id              The profileItem's identifer from Zanox
  # @attr [String]          name            The name of your ad space
  # @attr [String]          url             The url of your ad space
  # @attr [String]          description     The description for your ad space
  # @attr [String]          adspace_type    The type of ad space
  # @attr [Integer]         visitors        The number of visitors to your ad space
  # @attr [Integer]         impressions     The number of impressions of your ad space
  # @attr [String]          scope           The scope of your ad space
  # @attr [Array<String>]   regions         The regions for the ad space
  # @attr [Array<Category>] categories      The categories of your ad space
  # @attr [String]          language        The language of your ad space
  # @attr [Integer]         check_number    The check number for this ad space
  class AdSpace < Base
    RESOURCE_PATH = '/adspaces'

    ADSPACE_TYPE_ENUM = %w(website email searchengine)
    ADSPACE_SCOPE_ENUM = %w(private business)

    class << self
      # Retrieves all adspace items related to the publisher account.
      #
      # This is equivalent to the Zanox API method GetAdspaces.
      # The method documentation can be found under {https://developer.zanox.com/web/guest/publisher-api-2011/get-adspaces}.
      #
      # Authentication: Requires signature.
      #
      # This can require multiple requests, as internally every page is pulled.
      # The ZanoxPublisher::AdSpace.page function can be used to better control the requests made.
      #
      # @return [Array<AdSpace>]
      def all
        retval = []
        current_page = 0

        begin
          retval       += self.page(current_page, { per_page: maximum_per_page })
          current_page += 1
        end while AdSpace.total > retval.size

        retval
      end

      # Retrieves the requested page of adspace items related to the publisher account.
      #
      # This is equivalent to the Zanox API method GetAdspaces.
      # The method documentation can be found under {https://developer.zanox.com/web/guest/publisher-api-2011/get-adspaces}.
      #
      # Authentication: Requires signature.
      #
      # @param page [Integer] the page position
      # @param per_page [Integer] number of items in the result set (API equivalent is items)
      # @param items [Integer] number of items in the result set (API option name)
      #
      # @example
      #         ZanoxPublisher::AdSpace.page(1, per_page: 50) #=> [<AdSpace...>]
      #
      # @example
      #         ZanoxPublisher::AdSpace.page(2) #=> [<AdSpace...>]
      #
      # @example
      #         ZanoxPublisher::AdSpace.page #=> [<AdSpace...>]
      #
      # @return [Array<AdSpace>]
      def page(page = 0, options = {})
        params = { query: { page: page } }

        per_page = nil
        per_page = options[:per_page] if per_page.nil?
        per_page = options[:items]    if per_page.nil?
        per_page = AdSpace.per_page   if per_page.nil?
        params[:query].merge!({ items: per_page })

        retval = []

        response = self.connection.signature_get(RESOURCE_PATH, params)

        AdSpace.total = response.fetch('total')
        adspaces = response.fetch('adspaceItems', []).fetch('adspaceItem', [])

        adspaces.each do |adspace|
          retval << AdSpace.new(adspace)
        end

        retval
      end

      # Returns a single adspaceItem, as queried by its ID.
      #
      # This is equivalent to the Zanox API method GetAdspace.
      # The method documentation can be found under {https://developer.zanox.com/web/guest/publisher-api-2011/get-adspaces-adspace}.
      #
      # Authentication: Requires signature.
      #
      # @param id [Integer] the ID of the adspace you want to get
      #
      # @return [<AdSpace>, nil]
      def find(id)
        response = self.connection.signature_get(RESOURCE_PATH + "/adspace/#{id}")
        adspace = response.fetch('adspaceItem', []).first

        if adspace.nil? or adspace.empty?
          return nil
        end

        AdSpace.new(adspace)
      end

      # A connection instance with AdSpaces' relative_path
      #
      # @return [Connection]
      def connection
        @connection ||= Connection.new(RESOURCE_PATH)
      end
    end

    # TODO: POST   {https://developer.zanox.com/web/guest/publisher-api-2011/post-adspaces-adspace}
    # TODO: PUT    {https://developer.zanox.com/web/guest/publisher-api-2011/put-adspaces-adspace}
    # TODO: DELETE {https://developer.zanox.com/web/guest/publisher-api-2011/delete-adspaces-adspace}
    #
    def initialize(data = {})
      @id             = data.fetch('@id').to_i

      # Depending on short or long representation of object
      if data.fetch('$', nil).nil?
        @name           = data.fetch('name')
        @url            = data.fetch('url')
        @description    = data.fetch('description')
        @adspace_type   = data.fetch('adspaceType')
        @visitors       = data.fetch('visitors')
        @impressions    = data.fetch('impressions')
        @scope          = data.fetch('scope', nil)
        @regions        = data.fetch('regions', []).first
        @regions        = @regions.fetch('region') unless @regions.nil?
        @regions        = [@regions] if @regions.is_a? String
        @categories     = Category.fetch(data['categories'])
        @language       = data.fetch('language')
        @check_number   = data.fetch('checkNumber')
      else
        @name                 = data.fetch('$')
      end
    end

    # Returns the adspaceItems' ID as integer representation
    #
    # @return [Integer]
    def to_i
      @id
    end

    attr_accessor :id, :name, :url, :description, :adspace_type,
      :visitors, :impressions, :scope, :regions,
      :categories, :language, :check_number

    # make API names available
    alias adspaceType adspace_type
    alias checkNumber check_number
  end
end
