module ZanoxPublisher
  # @attr [Integer] adspace     The adspaces' ID for which the tracking link is set
  # @attr [String]  ppv         The Pay Per View tracking link
  # @attr [String]  ppc         The Pay Per Click tracking link
  # @attr [String]  tpv         The True Post View tracking link
  class TrackingLink
    class << self
      # Fetch all tracking links from Zanox API Response
      #
      # @param data [Array] the value of the 'trackingLinks' element
      #
      # @return [Array<TrackingLink>, nil]
      def fetch(data = nil)
        # To support API of picking categories of hash with [] notation
        return nil if data.nil? or not data.respond_to? :each

        retval = []

        data.each do |tracking_link|
          retval << TrackingLink.new(tracking_link)
        end

        retval
      end
    end
    attr_reader :adspace, :ppv, :ppc

    def initialize(data = {})
      @adspace = data.fetch('@adspaceId').to_i
      @ppv     = data.fetch('ppv')
      @ppc     = data.fetch('ppc')
      @tpv     = data.fetch('tpv', nil)
    end

    def to_i
      @adspace
    end
  end
end
