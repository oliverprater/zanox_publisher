module ZanoxPublisher
  class Policy
    class << self
      def fetch(data = nil)
        # To support API of picking categories of hash with [] notation
        return nil if data.nil?

        # Try to fetch policy else make data it an array
        policies = data.fetch('policy', nil)
        policies = [data]     if policies.nil?
        policies = [policies] if policies.is_a? Hash

        # Build the return value
        retval = []

        policies.each do |policy|
          retval << Policy.new(policy)
        end

        retval
      end
    end

    attr_reader :id, :name

    def initialize(data = {})
      @id   = data.fetch('@id').to_i
      @name = data.fetch('$', nil)
    end

    def to_s
      @name
    end

    # Returns the policy ID as integer representation
    #
    # @return [Integer]
    def to_i
      @id
    end
  end
end
