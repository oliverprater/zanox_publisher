module ZanoxPublisher
  # @attr [Integer]   id                    The programItem's identifer from Zanox
  # @attr [String]    name                  The name of the advertiser
  # @attr [Fixnum]    adrank                The adrank of the advertiser
  # @attr [Boolean]   application_required  States whether a direct application is required
  # @attr [String]    description           The description from the advertiser
  # @attr [String]    description_local     The description from the advertiser in connect ID language
  # @attr [Integer]   products              The number of products from the advertiser
  # @attr [Hash?]     vertical              The vertical of the advertiser
  # @attr [Array]     regions               The regions the advertiser is active in
  # @attr [Array]     categories            The categories of the advertiser
  # @attr [DateTime]  start_date            The start date of the program
  # @attr [String]    url                   The url for the program
  # @attr [String]    image                 The image for the program
  # @attr [String]    currency              The currency of the program
  # @attr [String]    status                The status of the program, with active stating the program is still a live
  # @attr [String]    terms                 The terms of the program
  # @attr [String]    terms_url             The terms url
  # @attr [Array]     policies              The policies of the program
  # @attr [String]    return_time_leads     The return time in which a lead is given
  # @attr [String]    return_time_sales     The return time in which a sale is given
  class Program < Base
    RESOURCE_PATH = '/programs'

    PROGRAM_STATUS_ENUM = %w(active inactive)

    class << self
      # Retrieves all programs dependent on search parameters.
      #
      # This can require multiple requests, as internally every page is pulled.
      # The ZanoxPublisher::Program.page function can be used to better control the requests made.
      #
      # @param query [String] Limits results to programs associated with this search string (API equivalent is q).
      # @param q [String] Limits results to programs associated with this search string (API name).
      # @param start_date [Date] Limits results to programs activated after this date (API equivalent is startdate).
      # @param startdate [Date] Limits results to programs activated after this date (API name).
      # @param region [String] Limits results to a particular region.
      # @param partnership [String] Limits results to programs with mandatory direct applications ("DIRECT") or not requiring direct application ("INDIRECT").
      # @param has_products [Boolean] Limits results to programs with products (API equivalent is hasproducts).
      # @param hasproducts [Boolean] Limits results to programs with products (API name).
      #
      # @return [Array<Program>]
      def all(options = {})
        retval = []
        current_page = 0
        options.merge!({ per_page: maximum_per_page })

        begin
          retval       += self.page(current_page, options)
          current_page += 1
        end while Program.total > retval.size

        retval
      end

      # Returns a list of programItems
      #
      # This is equivalent to the Zanox API method SearchPrograms.
      # The method documentation can be found under {https://developer.zanox.com/web/guest/publisher-api-2011/get-programs}.
      #
      # Authentication: Requires connect ID.
      #
      # @param page [Integer] the page position
      # @param per_page [Integer] number of items in the result set (API equivalent is items)
      # @param items [Integer] number of items in the result set (API name)
      # @param query [String] Limits results to programs associated with this search string (API equivalent is q).
      # @param q [String] Limits results to programs associated with this search string (API name).
      # @param start_date [Date] Limits results to programs activated after this date (API equivalent is startdate).
      # @param startdate [Date] Limits results to programs activated after this date (API name).
      # @param region [String] Limits results to a particular region.
      # @param partnership [String] Limits results to programs with mandatory direct applications ("DIRECT") or not requiring direct application ("INDIRECT").
      # @param has_products [Boolean] Limits results to programs with products (API equivalent is hasproducts).
      # @param hasproducts [Boolean] Limits results to programs with products (API name).
      #
      # @return [Array<Program>]
      def page(page = 0, options = {})
        params = { query: { page: page } }

        per_page = nil
        per_page = options[:per_page] if per_page.nil?
        per_page = options[:items]    if per_page.nil?
        per_page = Program.per_page   if per_page.nil?
        params[:query].merge!({ items: per_page })

        q = options[:query]
        q = options[:q]     if q.nil?

        start_date = options[:start_date]
        start_date = options[:startdate] if start_date.nil?
        start_date = nil unless start_date.respond_to? :strftime
        start_date = start_date.strftime('%Y-%m-%d') unless start_date.nil?

        region = options[:region]

        partnership = options[:partnership]

        has_products = options[:has_products]
        has_products = options[:hasproducts]  if has_products.nil?

        params[:query].merge!({ q: q })                       unless q.nil?
        params[:query].merge!({ startdate: start_date })      unless start_date.nil?
        params[:query].merge!({ region: region })             unless region.nil?
        params[:query].merge!({ partnership: partnership })   unless partnership.nil?
        params[:query].merge!({ hasproducts: has_products })  unless has_products.nil?

        retval = []

        response = self.connection.get(RESOURCE_PATH, params)

        Program.total = response.fetch('total')
        programs = response.fetch('programItems', []).fetch('programItem', [])

        programs.each do |program|
          retval << Program.new(program)
        end

        retval
      end

      # Request an programItem by its ID.
      #
      # This is equivalent to the Zanox API method GetProgram.
      # The method documentation can be found under {https://developer.zanox.com/web/guest/publisher-api-2011/get-programs-program}.
      #
      # Authentication: Requires connect ID.
      #
      # @param id [Program, Integer] the ID of the program you want to get.
      #
      # @return [<Program>]
      def find(id)
        response = self.connection.get(RESOURCE_PATH + "/program/#{id.to_i}")
        progam = response.fetch('programItem', []).first

        Program.new(progam)
      end

      # Get all program categories, including names and IDs, associated to the connect ID.
      #
      # This is equivalent to the Zanox API method GetProgramCategories.
      # The method documentation can be found under {https://developer.zanox.com/web/guest/publisher-api-2011/get-programs-categories}.
      #
      # # UNSURE IF BOTH CATEGORY OBJECTS DESCRIBE SAME THING WHEN ID IS SAME ???
      # NOTE: ONCE IT STATES admediaCategories AND OTHER JUST Category (FOR PROGRAM)
      #
      # Authentication: Requires connect ID.
      #
      # @return [<Category>]
      def categories
        response = self.connection.get(RESOURCE_PATH + '/categories')
        Category.fetch(response['categories'])
      end

      # A connection instance with Programs' relative_path
      #
      # @return [Connection]
      def connection
        @connection ||= Connection.new(RESOURCE_PATH)
      end
    end

    # Retrieve AdMedia categories for this program.
    #
    # Returns a list of the advertiser-defined, program-specific ad media categories.
    #
    # This is equivalent to the Zanox API method GetAdmediumCategories.
    # The method documentation can be found under {https://developer.zanox.com/web/guest/publisher-api-2011/get-admedia-categories-program}.
    #
    # NOTE: The returned ad media categories are different from progam categories
    #
    # Authentication: Requires connect ID.
    #
    # @return [<Category>]
    def admedia_categories
      response = Program.connection.get("/admedia/categories/program/#{@id}")

      Category.fetch(response['categories'])
    end

    # Programs
    #
    # Get advertiser programs
    #
    def initialize(data = {})
      @id                   = data.fetch('@id').to_i

      # Depending on short or long representation of object
      if data.fetch('$', nil).nil?
        @name                 = data.fetch('name')
        @adrank               = data.fetch('adrank')
        @application_required = data.fetch('applicationRequired')
        @description          = data.fetch('description')
        @description_local    = data.fetch('descriptionLocal', nil)
        @products             = data.fetch('products')
        @vertical             = data.fetch('vertical', nil)
        @regions              = data.fetch('regions', []).first
        @regions              = @regions.fetch('region') unless @regions.nil?
        @regions              = [@regions] if @regions.is_a? String
        @categories           = data.fetch('categories', nil)
        @categories           = Category.fetch(@categories) unless @categories.nil?
        @start_date           = Date.strptime(data.fetch('startDate'), "%Y-%m-%dT%H:%M:%S%z")
        @url                  = data.fetch('url')
        @image                = data.fetch('image')
        @currency             = data.fetch('currency')
        @status               = data.fetch('status')
        @terms                = data.fetch('terms', nil)
        @terms_url            = data.fetch('termsUrl', nil)
        @policies             = data.fetch('policies', nil)
        @return_time_leads    = data.fetch('returnTimeLeads', nil)
        @return_time_sales    = data.fetch('returnTimeSales', nil)
      else
        @name                 = data.fetch('$')
      end
    end

    # Returns the programItems' ID as integer representation
    #
    # @return [Integer]
    def to_i
      @id
    end

    attr_accessor :id, :name, :adrank, :application_required, :description,
                  :description_local, :products, :vertical, :regions, :categories,
                  :start_date, :url, :image, :currency, :status, :terms, :terms_url,
                  :policies, :return_time_leads, :return_time_sales

    # make API names available
    alias applicationRequired application_required
    alias application_required? application_required
    alias descriptionLocal description_local
    alias startDate start_date
    alias termsUrl terms_url
    alias returnTimeLeads return_time_leads
    alias returnTimeSales return_time_sales
  end
end
