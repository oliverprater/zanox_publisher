module ZanoxPublisher
  # Wrapper for the prizes response from Zanox API
  class Prize
    attr_reader :id, :name, :description, :count, :rank

    def initialize(data = {})
      @id           = data.fetch('@id')
      @name         = data.fetch('name')
      @description  = data.fetch('description')
      @count        = data.fetch('count')
      @rank         = data.fetch('rank')
    end

    def to_i
      @id
    end
  end
end
