module ZanoxPublisher
  # Incentives - Get coupons and other incentives
  #
  # The Zanox API cannot retrieve both exclusive and non-exclusive incentives, so each has its own class.
  class Incentive < IncentiveBase
    RESOURCE_PATH = '/incentives'

    # Set the exclusive attribute
    @@exclusive = false

    class << self
      # Retrieves all incentive's dependent on search parameters.
      #
      # This is equivalent to the Zanox API method SearchIncentives.
      # The method documentation can be found under {https://developer.zanox.com/web/guest/publisher-api-2011/get-incentives}.
      #
      # Authentication: Requires connect ID.
      #
      # This can require multiple requests, as internally every page is pulled.
      # The ZanoxPublisher::AdMedium.page function can be used to better control the requests made.
      #
      # @param program [Program, Integer] limits results to a particular program ID.
      # @param adspace [AdSpace, Integer] limits results to incentives that have tracking links associated with this AdSpace.
      # @param incentive_type [String] limits results to one of the following incentive types (API equivalent is incentiveType).
      # @param incentiveType [String] limits results to one of the following incentive types (API name).
      # @param region [String] limits results to a region.
      #
      # @return [Array<Incentive>]
      def all(options = {})
        retval = []
        current_page = 0
        options.merge!({ per_page: maximum_per_page })

        loop do
          response      = self.page(current_page, options)

          # This break is required as some give 0 elements, but set total value
          break if response.nil? or response.empty?

          retval       += response

          # This is the normal break when all pages have been processed
          break unless Incentive.total > retval.size

          current_page += 1
        end

        retval
      end

      # Retrieves a list of publicly available, non-exclusive incentiveItems dependent on search parameter.
      #
      # This is equivalent to the Zanox API method SearchIncentives.
      # The method documentation can be found under {https://developer.zanox.com/web/guest/publisher-api-2011/get-incentives}.
      #
      # Authentication: Requires connect ID.
      #
      # @param page [Integer] the page position.
      # @param per_page [Integer] number of items in the result set (API equivalent is items).
      # @param items [Integer] number of items in the result set (API name).
      # @param program [Program, Integer] limits results to a particular program ID.
      # @param adspace [AdSpace, Integer] limits results to incentives that have tracking links associated with this AdSpace.
      # @param incentive_type [String] limits results to one of the following incentive types (API equivalent is incentiveType).
      # @param incentiveType [String] limits results to one of the following incentive types (API name).
      # @param region [String] limits results to a region.
      #
      # @return [Array<Incentive>]
      def page(page = 0, options = {})
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
        incentive_type = nil unless @@incentive_types.include? incentive_type

        region = options[:region]

        # Build the query on hand of the options received
        params[:query].merge!({ program: program })               unless program.nil?
        params[:query].merge!({ adspace: adspace })               unless adspace.nil?
        params[:query].merge!({ incentiveType: incentive_type })  unless incentive_type.nil?
        params[:query].merge!({ region: region })                 unless region.nil?

        retval = []

        response = self.connection.get(RESOURCE_PATH, params)

        Incentive.total = response.fetch('total')

        incentives = []
        incentives = response.fetch('incentiveItems', {}).fetch('incentiveItem', []) if Incentive.total > 0
        incentives = [incentives] unless incentives.is_a? Array

        incentives.each do |incentive|
          retval << Incentive.new(incentive, @@exclusive)
        end

        retval
      end

      # Returns a single incentiveItem, as queried by its ID.
      #
      # This is equivalent to the Zanox API method GetIncentive.
      # The method documentation can be found under {https://developer.zanox.com/web/guest/publisher-api-2011/get-incentives-incentive}.
      #
      # Authentication: Requires connect ID.
      #
      # @param id [Integer] the ID of the adspace you want to get.
      # @param adspace [AdSpace, Integer] if you would like tracking links for only one of your publisher ad spaces, pass its ID in this parameter.
      #
      # @return [<Incentive>]
      def find(id, options = {})
        params  = {}

        adspace = options[:adspace]
        adspace = adspace.to_i unless adspace.nil?

        params  = { query: { adspace: adspace } } unless adspace.nil?

        response = self.connection.get(RESOURCE_PATH + "/incentive/#{id.to_i}", params)

        Incentive.new(response.fetch('incentiveItem'), @@exclusive)
      end

      # A connection instance with Incentives' relative_path
      #
      # @return [Connection]
      def connection
        @connection ||= Connection.new(RESOURCE_PATH)
      end
    end
  end
end
