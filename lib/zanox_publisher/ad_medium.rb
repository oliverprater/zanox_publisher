module ZanoxPublisher
  # @attr [Integer]         id              The admediumItem's identifer from Zanox
  # @attr [String]          name            The name for the admedium
  # @attr [Fixnum]          adrank          The adrank of the admedium
  # @attr [String]          admedium_type   The type of admedium
  # @attr [Program]         program         The program to which the admedium belongs
  # @attr [String]          title           The title of the admedium
  # @attr [Integer]         height          The height of the image
  # @attr [Integer]         width           The width of the image
  # @attr [Hash]            format          The
  # @attr [String]          code            The
  # @attr [String]          description     The
  # @attr [String]          instruction     The
  # @attr [String]          purpose         The
  # @attr [Array<Category>] category        The
  # @attr [Hash]            group           The
  # @attr [Array]           tags            The
  # @attr [Array]           tracking_links  The
  class AdMedium < Base
    RESOURCE_PATH = '/admedia'

    # ENUM types
    ADMEDIA_TYPE_ENUM    = %w(html script lookatMedia image imageText text)
    ADMEDIA_PURPOSE_ENUM = %w(startPage productDeeplink categoryDeeplink searchDeeplink)

    class << self
      # Retrieves all affiliate link's dependent on search parameters.
      #
      # This can require multiple requests, as internally every page is pulled.
      # The ZanoxPublisher::AdMedium.page function can be used to better control the requests made.
      #
      # @param program [Integer] Limits results to a particular program ID.
      # @param region [String] Limits results to programs from a particular region.
      # @param format [String] Limits results to an ad media format.
      # @param admedium_type [String] Limits results to an ad media type (API equivalent is admediumtype).
      # @param admediumtype [String] Limits results to an ad media type (API name).
      # @param purpose [String] Limits results to a type of link to the advertiser shop.
      # @param partnership [String] Limits results to either programs to whom the publisher has successfully applied ("direct"), or to those who belong to zanox's publicly available ad pool ("indirect").
      # @param category [String] Limits results to one of the program's ad media categories. Ad media categories are defined by each advertiser for their program, and can be retrieved using GetAdmediumCategories.
      # @param adspace [AdSpace, Integer] Limits results to tracking links associated with this ad space.
      #
      # @return [Array<AdMedium>]
      def all(options = {})
        retval = []
        current_page = 0
        options.merge!({ per_page: maximum_per_page })

        begin
          retval       += self.page(current_page, options)
          current_page += 1
        end while AdMedium.total > retval.size

        retval
      end

      # Retrieves the requested page of admedium items dependent on search parameters.
      #
      # This is equivalent to the Zanox API method GetAdmedia.
      # The method documentation can be found under {https://developer.zanox.com/web/guest/publisher-api-2011/get-admedia}.
      #
      # Authentication: Requires connect ID.
      #
      # @param page [Integer] the page position
      # @param per_page [Integer] number of items in the result set (API equivalent is items)
      # @param items [Integer] number of items in the result set (API name)
      # @param program [Program, Integer] Limits results to a particular program ID.
      # @param region [String] Limits results to programs from a particular region.
      # @param format [String] Limits results to an ad media format.
      # @param admedium_type [String] Limits results to an ad media type (API equivalent is admediumtype).
      # @param admediumtype [String] Limits results to an ad media type (API name).
      # @param purpose [String] Limits results to a type of link to the advertiser shop.
      # @param partnership [String] Limits results to either programs to whom the publisher has successfully applied ("direct"), or to those who belong to zanox's publicly available ad pool ("indirect").
      # @param category [Category, String] Limits results to one of the program's ad media categories. Ad media categories are defined by each advertiser for their program, and can be retrieved using GetAdmediumCategories.
      # @param adspace [AdSpace, Integer] Limits results to tracking links associated with this ad space.
      #
      # @return [Array<AdSpace>]
      def page(page = 0, options = {})
        params = { query: { page: page } }

        per_page = nil
        per_page = options[:per_page] if per_page.nil?
        per_page = options[:items]    if per_page.nil?
        per_page = AdMedium.per_page  if per_page.nil?
        params[:query].merge!({ items: per_page })

        program = options[:program]
        program = program.to_i        unless program.nil?

        region = options[:region]

        format = options[:format]

        admedium_type = options[:admedium_type]
        admedium_type = options[:admediumtype]  if admedium_type.nil?
        admedium_type = nil unless ADMEDIA_TYPE_ENUM.include? admedium_type

        purpose = options[:purpose]
        purpose = nil unless ADMEDIA_PURPOSE_ENUM.include? purpose

        partnership = options[:partnership]

        # Limits results to one of the program's ad media categories. Ad media categories are defined by each advertiser for their program, and can be retrieved using GetAdmediumCategories.
        category = options[:category]
        category = category.to_i unless category.nil?

        adspace = options[:adspace]
        adspace = adspace.to_i unless adspace.nil?

        # Build the query on hand of the options received
        params[:query].merge!({ program: program })             unless program.nil?
        params[:query].merge!({ region: region })               unless region.nil?
        params[:query].merge!({ format: format })               unless format.nil?
        params[:query].merge!({ admediumtype: admedium_type })  unless admedium_type.nil?
        params[:query].merge!({ purpose: purpose })             unless purpose.nil?
        params[:query].merge!({ partnership: partnership })     unless partnership.nil?
        params[:query].merge!({ category: category })           unless category.nil?
        params[:query].merge!({ adspace: adspace })             unless adspace.nil?

        retval = []

        response = self.connection.get(RESOURCE_PATH, params)

        AdMedium.total = response.fetch('total')

        admedia = []
        admedia = response.fetch('admediumItems', {}).fetch('admediumItem', []) if AdMedium.total > 0

        admedia.each do |admedium|
          retval << AdMedium.new(admedium)
        end

        retval
      end

      # Returns a single admediumItem, as queried by its ID.
      #
      # The use of the trackingLink of the ID is not supported at the moment.
      #
      # This is equivalent to the Zanox API method GetAdmedium.
      # The method documentation can be found under {https://developer.zanox.com/web/guest/publisher-api-2011/get-admedia-admedium}.
      #
      # Authentication: Requires connect ID.
      #
      # @param id [Integer] the ID of the adspace you want to get.
      # @param adspace [AdSpace, Integer] if you would like tracking links for only one of your publisher ad spaces, pass its ID in this parameter.
      #
      # @return [<AdMedium>]
      def find(id, options = {})
        params  = {}

        adspace = options[:adspace]
        adspace = adspace.to_i unless adspace.nil?

        params  = { query: { adspace: adspace } } unless adspace.nil?

        response = self.connection.get(RESOURCE_PATH + "/admedium/#{id}", params)
        admedium = response.fetch('admediumItem', [])

        AdMedium.new(admedium)
      end

      # A connection instance with AdMediums' relative_path
      #
      # @return [Connection]
      def connection
        @connection ||= Connection.new(RESOURCE_PATH)
      end
    end

    # AdMedium
    #
    # Get banners and links, including tracking links
    #
    def initialize(data = {})
      @id             = data.fetch('@id').to_i
      @name           = data.fetch('name')
      @adrank         = data.fetch('adrank')
      @admedium_type  = data.fetch('admediumType')
      @program        = Program.new(data.fetch('program'))
      # Optionally returned data
      @title          = data.fetch('title', nil)
      @height         = data.fetch('height', nil)
      @width          = data.fetch('width', nil)
      @format         = data.fetch('format', nil)
      @format         = Format.new(@format) unless @format.nil?
      @code           = data.fetch('code', nil)
      @description    = data.fetch('description', nil)
      @instruction    = data.fetch('instruction', nil)
      @purpose        = data.fetch('purpose', nil)
      @category       = data.fetch('category', nil)
      @category       = Category.new(@category) unless @category.nil?
      @group          = data.fetch('group', nil)
      @tags           = data.fetch('tags', nil)
      @tracking_links = TrackingLink.fetch(data.fetch('trackingLinks', {})['trackingLink'])
    end

    def to_i
      @id
    end

    attr_accessor :id, :name, :adrank, :admedium_type, :program,
                  :title, :height, :width, :format, :code,
                  :description, :instruction, :purpose, :category,
                  :group, :tags, :tracking_links

    # make API names available
    alias admediumType admedium_type
    alias trackingLinks tracking_links
  end
end
