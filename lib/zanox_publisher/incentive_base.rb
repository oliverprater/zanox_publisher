module ZanoxPublisher
  # Base class to hold the incentive attributes
  #
  # @attr [Integer]         id                    The incentiveItem's identifer from Zanox
  # @attr [String]          name                  The name for the incentive
  # @attr [Program]         program               The program to which the incentive belongs
  # @attr [Array<AdMedium>] admedium              The ad medium that can be used for the incentive
  # @attr [String]          incentive_type        The type of incentive
  # @attr [Array<String>]   regions               The regions for the incentive
  # @attr [DateTime]        created_at            The date the incentive is created at
  # @attr [DateTime]        modified_at           The date the incentive is modified at
  # @attr [DateTime]        start_date            The date the incentive will start
  # @attr [DateTime]        end_date              The date the incentive will end
  # @attr [String]          info_for_publisher    The information for the publisher
  # @attr [String]          info_for_customer     The information for the customer
  # @attr [String]          coupon_code           The coupon code assigned to the incentive
  # @attr [Fixnum]          total                 The total amount saved through the incentive
  # @attr [String]          currency              The currency of money amounts
  # @attr [Fixnum]          percentage            The rebate percentage given through the incentive
  # @attr [String]          restrictions          Any restrictions associated with the incentive
  # @attr [Boolean]         new_customer_only     States if the incentive is only for new customers
  # @attr [Fixnum]          minimum_basket_value  The minimum basket value to trigger the incentive
  # @attr [Array<Prize>]    prizes                The prizes given during the incentive
  class IncentiveBase < Base
    @@incentive_types = %w(coupons samples bargains freeProducts noShippingCosts lotteries)

    # Returns the Zanox API incentiveTypeEnum datatype
    #
    # @return [Array<String>]
    def self.incentive_types
      @@incentive_types
    end

    def initialize(data = {}, exclusive = false)
      @id                   = data.fetch('@id')
      @name                 = data.fetch('name')
      @program              = Program.new(data.fetch('program'))
      @admedium             = AdMedium.new(data.fetch('admedia').fetch('admediumItem'))
      @incentive_type       = data.fetch('incentiveType')
      @regions              = data.fetch('regions', []).first
      @regions              = @regions.fetch('region') unless @regions.nil?
      @regions              = [@regions] if @regions.is_a? String
      @created_at           = data.fetch('createDate')
      @modified_at          = data.fetch('modifiedDate')
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
      @prizes               = data.fetch('prizes', '')
      @prizes               = nil if @prizes == ''
      @prizes               = @prizes.fetch('prize') unless @prizes.nil?
      @prizes               = @prizes.map{ |hash| Prize.new(hash) } unless @prizes.nil?
      @exclusive            = exclusive
    end

    # Returns the incentiveItems' ID as integer representation
    #
    # @return [Integer]
    def to_i
      @id
    end

    attr_accessor :id, :name, :program, :admedium, :incentive_type,
                  :regions, :created_at, :modified_at, :start_date,
                  :end_date, :info_for_publisher, :info_for_customer,
                  :coupon_code, :total, :currency, :percentage, :restrictions,
                  :new_customer_only, :minimum_basket_value, :prizes, :exclusive

    # make API names available
    alias admedia admedium
    alias incentiveType incentive_type
    alias createDate created_at
    alias modifiedDate modified_at
    alias startDate start_date
    alias endDate end_date
    alias info4publisher info_for_publisher
    alias info4customer info_for_customer
    alias couponCode coupon_code
    alias newCustomerOnly new_customer_only
    alias minimumBasketValue minimum_basket_value
  end
end
