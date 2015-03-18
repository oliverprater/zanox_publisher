module ZanoxPublisher
  # Products
  #
  # Get products, including their tracking links
  #
  # @attr [String]              id                    The productItem's identifer from Zanox
  # @attr [String]              name                  The name for the product
  # @attr [DateTime]            modified_at           The date the incentive is modified at
  # @attr [Program]             program               The program to which the product belongs
  # @attr [Fixnum]              price                 The price of the product
  # @attr [String]              currency              The currency of the price
  # @attr [Array<TrackingLink>] tracking_links        The tracking links of the product for each ad space
  # @attr [String]              description           The product description
  # @attr [String]              description_long      The long version of the product description
  # @attr [String]              manufacturer          The products' manufacturer
  # @attr [String]              ean                   The products' EAN
  # @attr [String]              delivery_time         The delivery time for the product
  # @attr [String]              terms                 The terms and conditions of the product
  # @attr [Category]            category              The advertisers' given category to the product
  # @attr [Hash]                image                 The product image's
  # @attr [Fixnum]              price_old             The old price of the product
  # @attr [String]              shipping_costs        The shipping costs for the product
  # @attr [String]              shipping              The shipping costs for the product
  # @attr [String]              merchant_category     The merchants' category for the product
  # @attr [String]              merchant_product_id   The merchants' product ID
  class Product < Base
    RESOURCE_PATH = '/products'

    class << self
      # Retrieves all products dependent on search parameters.
      #
      # This is equivalent to the Zanox API method SearchProducts.
      # The method documentation can be found under {https://developer.zanox.com/web/guest/publisher-api-2011/get-products}.
      #
      # Authentication: Requires connect ID.
      #
      # This can require multiple requests, as internally every page is pulled.
      # The ZanoxPublisher::Product.page function can be used to better control the requests made.
      #
      # @param query [String] Limits results to programs associated with this search string (API equivalent is q).
      # @param q [String] Limits results to programs associated with this search string (API name).
      # @param region [String] Limits results to a particular region.
      # @param minimum_price [Integer] Limits results to products with a minimum, currency-independent price (API equivalent is minprice).
      # @param minprice [Integer] Limits results to products with a minimum, currency-independent price (API name).
      # @param maximum_price [Integer] Limits results to products with a maximum, currency-independent price (API equivalent is maxprice).
      # @param maxprice [Integer] Limits results to products with a maximum, currency-independent price (API name).
      # @param programs [Program, Integer, Array<Program>, Array<Integer>] Limits results to particular program ID(s).
      # @param has_images [Boolean] Limits results to products with images (API equivalent is hasimages).
      # @param hasimages [Boolean] Limits results to products with images (API name).
      # @param adspace [AdSpace, Integer] limits results to incentives that have tracking links associated with this AdSpace.
      # @param partnership [String] Enables search in all product data regardless of whether you are confirmed by the advertiser or not.
      # @param ean [Integer, String] Limit on hand of the international article number.
      # @param merchant_category [String, Array<String>] Limits results to the specified merchant category/categories.
      # @param merchantcategory [String, Array<String>] Limits results to the specified merchant category/categories.
      #
      # @return [Array<Product>]
      def all(options = {})
        retval = []
        current_page = 0
        options.merge!({ per_page: maximum_per_page })

        begin
          retval       += self.page(current_page, options)
          current_page += 1
        end while Product.total > retval.size

        retval
      end

      # Retrieves the requested page of product items dependent on search parameters.
      #
      # This is equivalent to the Zanox API method SearchProducts.
      # The method documentation can be found under {https://developer.zanox.com/web/guest/publisher-api-2011/get-products}.
      #
      # Authentication: Requires connect ID.
      #
      # @param page [Integer] the page position
      # @param per_page [Integer] number of items in the result set (API equivalent is items)
      # @param items [Integer] number of items in the result set (API name)
      # @param query [String] Limits results to programs associated with this search string (API equivalent is q).
      # @param q [String] Limits results to programs associated with this search string (API name).
      # @param region [String] Limits results to a particular region.
      # @param minimum_price [Integer] Limits results to products with a minimum, currency-independent price (API equivalent is minprice).
      # @param minprice [Integer] Limits results to products with a minimum, currency-independent price (API name).
      # @param maximum_price [Integer] Limits results to products with a maximum, currency-independent price (API equivalent is maxprice).
      # @param maxprice [Integer] Limits results to products with a maximum, currency-independent price (API name).
      # @param programs [Program, Integer, Array<Program>, Array<Integer>] Limits results to particular program ID(s).
      # @param has_images [Boolean] Limits results to products with images (API equivalent is hasimages).
      # @param hasimages [Boolean] Limits results to products with images (API name).
      # @param adspace [AdSpace, Integer] limits results to incentives that have tracking links associated with this AdSpace.
      # @param partnership [String] Enables search in all product data regardless of whether you are confirmed by the advertiser or not.
      # @param ean [Integer, String] Limit on hand of the international article number.
      # @param merchant_category [String, Array<String>] Limits results to the specified merchant category/categories.
      # @param merchantcategory [String, Array<String>] Limits results to the specified merchant category/categories.
      #
      # @return [Array<Product>]
      def page(page = 0, options = {})
        params = { query: { page: page } }

        per_page = nil
        per_page = options[:per_page] if per_page.nil?
        per_page = options[:items]    if per_page.nil?
        per_page = Product.per_page  if per_page.nil?
        params[:query].merge!({ items: per_page })

        query = options[:query]
        query = options[:q]       if query.nil?

        if not query.nil?
          if query.length <= 25
            searchtype = 'phrase'
          else
            searchtype = 'contextual'
          end
        end

        region = options[:region]

        minimum_price = options[:minimum_price]
        minimum_price = options[:minprice]      if minimum_price.nil?
        minimum_price = minimum_price.to_i      unless minimum_price.nil?

        maximum_price = options[:maximum_price]
        maximum_price = options[:maxprice]      if maximum_price.nil?
        maximum_price = maximum_price.to_i      unless maximum_price.nil?

        programs = options[:programs]

        unless programs.nil?
          programs = programs.map(&:to_i).join(',') if programs.is_a? Array
          programs = programs.to_i                  if programs.is_a? Program or programs.is_a? Integer
        end

        has_images = options[:has_images]
        has_images = options[:hasimages]  if has_images.nil?

        adspace = options[:adspace]
        adspace = adspace.to_i unless adspace.nil?

        partnership = options[:partnership]
        partnership = nil unless ['all', 'confirmed'].include? partnership

        ean = options[:ean]

        merchant_category = options[:merchant_category]
        merchant_category = options[:merchantcategory]  if merchant_category.nil?

        unless merchant_category.nil?
          if merchant_category.is_a? Array
            merchant_category.each { |category| params[:query].merge!({ merchantcategory: category }) }
          else
            params[:query].merge!({ merchantcategory: merchant_category })
          end
        end

        params[:query].merge!({ q: query })                       unless query.nil?
        params[:query].merge!({ searchtype: searchtype })         unless query.nil?
        params[:query].merge!({ region: region })                 unless region.nil?
        params[:query].merge!({ minprice: minimum_price })        unless minimum_price.nil?
        params[:query].merge!({ maxprice: maximum_price })        unless maximum_price.nil?
        params[:query].merge!({ programs: programs })             unless programs.nil?
        params[:query].merge!({ hasimages: has_images })          unless has_images.nil?
        params[:query].merge!({ adspace: adspace })               unless adspace.nil?
        params[:query].merge!({ partnership: partnership })       unless partnership.nil?
        params[:query].merge!({ ean: ean })                       unless ean.nil?

        retval = []

        response = self.connection.get(RESOURCE_PATH, params)

        Product.total = response.fetch('total')

        products = []
        products = response.fetch('productItems', {}) if Product.total > 0
        products = {} unless products.is_a? Hash
        products = products.fetch('productItem', [])

        products.each do |product|
          retval << Product.new(product)
        end

        retval
      end

      # Returns a single productItem, as queried by its ID.
      #
      # This is equivalent to the Zanox API method GetProduct.
      # The method documentation can be found under {https://developer.zanox.com/web/guest/publisher-api-2011/get-products-product}.
      #
      # Authentication: Requires connect ID.
      #
      # @param id [Integer] the ID of the adspace you want to get.
      # @param adspace [AdSpace, Integer] if you would like tracking links for only one of your publisher ad spaces, pass its ID in this parameter.
      #
      # @return [<Product>]
      def find(id, options = {})
        params  = {}

        adspace = options[:adspace]
        adspace = adspace.to_i unless adspace.nil?

        params  = { query: { adspace: adspace } } unless adspace.nil?

        response = self.connection.get(RESOURCE_PATH + "/product/#{id.to_i}", params)

        Product.new(response.fetch('productItem').first)
      end

      # A connection instance with Products' relative_path
      #
      # @return [Connection]
      def connection
        @connection ||= Connection.new(RESOURCE_PATH)
      end
    end

    def initialize(data = {})
      @id                   = data.fetch('@id')
      @name                 = data.fetch('name')
      @modified_at          = data.fetch('modified')
      @program              = Program.new(data.fetch('program'))
      @price                = data.fetch('price')
      @currency             = data.fetch('currency')
      @tracking_links       = TrackingLink.fetch(data.fetch('trackingLinks', {})['trackingLink'])
      @description          = data.fetch('description', nil)
      @description_long     = data.fetch('descriptionLong', nil)
      @manufacturer         = data.fetch('manufacturer', nil)
      @ean                  = data.fetch('ean', nil)
      @delivery_time        = data.fetch('deliveryTime', nil)
      @terms                = data.fetch('terms', nil)
      @category             = data.fetch('category', nil)
      @category             = Category.new(@category) unless @category.nil?
      @image                = data.fetch('image', nil)
      @price_old            = data.fetch('priceOld', nil)
      @shipping_costs       = data.fetch('shippingCosts', nil)
      @shipping             = data.fetch('shipping', nil)
      @merchant_category    = data.fetch('merchantCategory', nil)
      @merchant_product_id  = data.fetch('merchantProductId', nil)
    end

    # Returns the productItems' ID as integer representation
    #
    # @return [Integer]
    def to_i
      @id
    end

    attr_accessor :id, :name, :modified_at, :program, :price, :currency, :tracking_links,
                  :description, :description_long, :manufacturer, :ean, :delivery_time,
                  :terms, :category, :image, :price_old, :shipping_costs, :shipping,
                  :merchant_category, :merchant_product_id

    # make API names available
    alias modified modified_at
    alias trackingLinks tracking_links
    alias descriptionLong description_long
    alias deliveryTime delivery_time
    alias priceOld price_old
    alias shippingCosts shipping_costs
    alias merchantCategory merchant_category
    alias merchantProductId merchant_product_id
  end
end
