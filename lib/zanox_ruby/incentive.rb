module ZanoxRuby
  # @attr [Integer]         id                    The admediumItem's identifer from Zanox
  # @attr [String]          name                  The
  # @attr [Program]         program               The
  # @attr [Array<AdMedium>] admedia               The
  # @attr [String]          incentive_type        The
  # @attr [Array<String>]   regions               The
  # @attr [DateTime]        create_date           The
  # @attr [DateTime]        modified_date         The
  # @attr [DateTime]        start_date            The
  # @attr [DateTime]        end_date              The
  # @attr [String]          info_for_publisher    The
  # @attr [String]          info_for_customer     The
  # @attr [String]          coupon_code           The
  # @attr [Fixnum]          total                 The
  # @attr [String]          currency              The
  # @attr [Fixnum]          percentage            The
  # @attr [String]          restrictions          The
  # @attr [Boolean]         new_customer_only     The
  # @attr [Fixnum]          minimum_basket_value  The
  # @attr [Array]           prizes                The
  class Incentive < Base
    RESOURCE_PATH = '/incentives'

    # ENUM types
    INCENTIVETYPEENUM = %w(coupons samples bargains freeProducts noShippingCosts lotteries)

    class << self
      # Retrieves all incentive's dependent on search parameters.
      #
      # This can require multiple requests, as internally every page is pulled.
      # The ZanoxRuby::AdMedium.page function can be used to better control the requests made.
      #
      # @param exclusive [Boolean] limit results to non-exclusive or exclusive incentive.
      # @param program [Program, Integer] limits results to a particular program ID.
      # @param adspace [AdSpace, Integer] limits results to incentives that have tracking links associated with this AdSpace.
      # @param incentive_type [String] limits results to one of the following incentive types (API equivalent is incentiveType).
      # @param incentiveType [String] limits results to one of the following incentive types (API name).
      # @param region [String] limits results to a region.
      #
      # @return [Array<Incentive>]
      def all(exclusive = false, options = {})
        retval = []
        current_page = 0
        options.merge!({ per_page: maximum_per_page })

        begin
          retval       += self.page(current_page, exclusive, options)
          current_page += 1
        end while Incentive.total > retval.size

        retval
      end

      # Retrieves a list of incentive's dependent on search parameter.
      #
      # The Zanox API cannot retrieve both exclusive and non-exclusive incentives, so the parameter exclusive is mandatory.
      #
      # With exclusive = false:
      # Returns a list of publicly available, non-exclusive incentiveItems.
      #
      # This is equivalent to the Zanox API method SearchIncentives.
      # The method documentation can be found under {https://developer.zanox.com/web/guest/publisher-api-2011/get-incentives}.
      #
      # Authentication: Requires connect ID.
      #
      # With exclusive = true:
      # Returns a list of exclusive incentiveItems.
      #
      # This is equivalent to the Zanox API method SearchExclusiveIncentives.
      # The method documentation can be found under {https://developer.zanox.com/web/guest/publisher-api-2011/get-incentives-exclusive}.
      #
      # Authentication: Requires signature.
      #
      # @param page [Integer] the page position.
      # @param per_page [Integer] number of items in the result set (API equivalent is items).
      # @param items [Integer] number of items in the result set (API name).
      # @param exclusive [Boolean] limit results to non-exclusive or exclusive incentive.
      # @param program [Program, Integer] limits results to a particular program ID.
      # @param adspace [AdSpace, Integer] limits results to incentives that have tracking links associated with this AdSpace.
      # @param incentive_type [String] limits results to one of the following incentive types (API equivalent is incentiveType).
      # @param incentiveType [String] limits results to one of the following incentive types (API name).
      # @param region [String] limits results to a region.
      #
      # @return [Array<Incentive>]
      def page(page = 0, exclusive = false, options = {})
        params = { query: { page: page } }

        per_page = nil
        per_page = options[:per_page] if per_page.nil?
        per_page = options[:items]    if per_page.nil?
        per_page = AdMedium.per_page  if per_page.nil?
        params[:query].merge!({ items: per_page })

        program = options[:program]
        program = program.to_i        unless program.nil?

        adspace = options[:adspace]
        adspace = adspace.to_i        unless adspace.nil?

        incentive_type = options[:incentive_type]
        incentive_type = options[:incentiveType]  if incentive_type.nil?
        incentive_type = nil unless INCENTIVETYPEENUM.include? incentive_type

        region = options[:region]

        # Build the query on hand of the options received
        params[:query].merge!({ program: program })               unless program.nil?
        params[:query].merge!({ adspace: adspace })               unless adspace.nil?
        params[:query].merge!({ incentiveType: incentive_type })  unless incentive_type.nil?
        params[:query].merge!({ region: region })                 unless region.nil?

        retval = []

        # Dependent on exclusive get the resource
        if exclusive
          response = self.connection.signature_get(RESOURCE_PATH + '/exclusive', params)
        else
          response = self.connection.get(RESOURCE_PATH, params)
        end

        Incentive.total = response.fetch('total')

        incentives = []
        incentives = response.fetch('incentiveItems', {}).fetch('incentiveItem', []) if Incentive.total > 0

        incentives.each do |incentive|
          retval << Incentive.new(incentive, exclusive)
        end

        retval
      end

      # Returns a single incentiveItem, as queried by its ID.
      #
      # with exclusive == false:
      #
      # This is equivalent to the Zanox API method GetIncentive.
      # The method documentation can be found under {https://developer.zanox.com/web/guest/publisher-api-2011/get-incentives-incentive}.
      #
      # Authentication: Requires connect ID.
      #
      # with exclusive == true:
      #
      # This is equivalent to the Zanox API method GetExclusiveIncentive.
      # The method documentation can be found under {https://developer.zanox.com/web/guest/publisher-api-2011/get-incentives-exclusive-incentive}.
      #
      # Authentication: Requires signature.
      #
      # @param id [Integer] the ID of the adspace you want to get.
      # @param exclusive [Boolean] limit results to non-exclusive or exclusive incentive.
      # @param adspace [AdSpace, Integer] if you would like tracking links for only one of your publisher ad spaces, pass its ID in this parameter.
      #
      # @return [<Incentive>]
      def find(id, exclusive = false, options = {})
        params  = {}

        adspace = options[:adspace]
        adspace = adspace.to_i unless adspace.nil?

        params  = { query: { adspace: adspace } } unless adspace.nil?

        if exclusive
          response = self.connection.signature_get(RESOURCE_PATH + "/exclusive/incentive/#{id}", params)
        else
          response = self.connection.get(RESOURCE_PATH + "/incentive/#{id}", params)
        end

        Incentive.new(response.fetch('incentiveItem'))
      end

      # A connection instance with Incentives' relative_path
      #
      # @return [Connection]
      def connection
        @connection ||= Connection.new(RESOURCE_PATH)
      end
    end

    def initialize(data = {}, exclusive = false)
      @id                   = data.fetch('@id')
      @name                 = data.fetch('name')
      @program              = Program.new(data.fetch('program'))
      @admedia              = AdMedium.new(data.fetch('admedia').fetch('admediumItem'))
      @incentive_type       = data.fetch('incentiveType')
      @regions              = data.fetch('regions')
      @create_date          = data.fetch('createDate')
      @modified_date        = data.fetch('modifiedDate')
      @start_date           = data.fetch('startDate')
      @end_date             = data.fetch('endDate', nil)
      @info_for_publisher   = data.fetch('info4publisher', nil)
      @info_for_customer    = data.fetch('info4customer')
      @coupon_code          = data.fetch('couponCode', nil)
      @total                = data.fetch('total', nil)
      @currency             = data.fetch('currency', nil)
      @percentage           = data.fetch('percentage', nil)
      @restrictions         = data.fetch('restrictions', nil)
      @new_customer_only    = data.fetch('newCustomerOnly')
      @minimum_basket_value = data.fetch('minimumBasketValue', nil)
      @prizes               = data.fetch('prizes', nil)
      @exclusive            = exclusive
    end

    def to_i
      @id
    end

    attr_accessor :id, :name, :program, :admedia, :incentive_type,
                  :regions, :create_date, :modified_date, :start_date,
                  :end_date, :info_for_publisher, :info_for_customer,
                  :coupon_code, :total, :currency, :percentage, :restrictions,
                  :new_customer_only, :minimum_basket_value, :prizes, :exclusive

    # make API names available
    alias incentiveType incentive_type
    alias createDate create_date
    alias modifiedDate modified_date
    alias startDate start_date
    alias endDate end_date
    alias info4publisher info_for_publisher
    alias info4customer info_for_customer
    alias couponCode coupon_code
    alias newCustomerOnly new_customer_only
    alias minimumBasketValue minimum_basket_value
  end
end
