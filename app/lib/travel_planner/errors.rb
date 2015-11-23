module TravelPlanner
  class Error < StandardError
    def message
      'An unexpected error occurred.'
    end
  end

  class ConnectionError < Error
    def message
      'The routing server could not be reached.'
    end
  end

  class InvalidCoordsError < Error
    def message
      'Supplied coordinates are invalid.'
    end
  end
end