module ZanoxPublisher
  # Wrapper for the vertical response from Zanox API
  class Vertical
    attr_reader :id, :name

    def initialize(data = {})
      @id   = data.fetch('@id').to_i
      @name = data.fetch('$')
    end

    def to_s
      @name
    end

    def to_i
      @id
    end
  end
end
