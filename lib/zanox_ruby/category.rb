module ZanoxRuby
  # Legacy name for category of program and admedium
  #
  # NOTE: ENSURE THAT include? WORKS WHEN GETTING STRING TO USE AN ARRAY<CATEGORY> TO VALIDATE
  #
  # @param [Integer] id     The identifer of the category
  # @param [String]  name   The name of the category
  class Category
    class << self
      # Fetch all categories from Zanox API Response
      #
      # @param data [Array] the value of the 'categories' element
      #
      # @return [Array<Category>, nil]
      def fetch(data = nil)
        # To support API of picking categories of hash with [] notation
        return nil if data.nil?
        categories = data.first
        # In case the array is empty first will return a nil
        return nil if categories.nil?
        categories = categories['category']
        # In case the second level is missing the hash [] notation will nil
        return nil if categories.nil?
        # In case just one category is in the list it must be converted back to an array
        categories = [categories] if categories.is_a? Hash

        # We got the array of category hash's
        retval = []

        categories.each do |category|
          retval << self.new(category)
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

    def to_i
      @id
    end
  end
end
