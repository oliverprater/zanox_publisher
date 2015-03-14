module ZanoxPublisher
  class Base
    # Pagination
    @@default_per_page = 10
    @@maximum_per_page = 50

    class << self
      # Getter for the maximum per page
      #
      # @return [Integer]
      def maximum_per_page
        @@maximum_per_page
      end

      # Set the number of items to request per page.
      #
      # @param number [Integer] The number of items per page (default = 10; maximum = 50)
      #
      # @return [Integer]
      #
      # @example
      #         ZanoxPublisher::AdSpace.per_page = 20     #=> 20
      #         first_page = ZanoxPublisher::AdSpace.page #=> [Array<AdSpace>]
      def per_page=(number)
        if number.to_i < 0
          @per_page = 0
        elsif number.to_i > @@maximum_per_page
          @per_page = @@maximum_per_page
        else
          @per_page = number.to_i
        end

        @per_page
      end

      # Returns the number of items to request per page.
      # The default of 10 is returned if per_page is not set.
      #
      # @return [Integer]
      def per_page
        @per_page ||= @@default_per_page
      end

      # Internally set total item count.
      #
      # @param number [Integer] The total items from the API response
      #
      # @return [Integer]
      def total=(number)
        @total = number
      end

      # Returns the total number of items or nil in case no page was requested
      #
      # @return [Integer, nil]
      #
      # @example
      #         data = []
      #         number = 0
      #         do
      #           data << ZanoxPublisher::AdSpace.page(number)
      #           number += 1
      #         end while data.size < ZanoxPublisher::AdSpace.total
      def total
        @total
      end
    end
  end
end
