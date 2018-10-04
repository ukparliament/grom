module Grom
  # A Ruby object populated with Grom::Nodes and Grom::Labels.
  #
  # @attr_reader [Array] objects Grom::Node objects generated from n-triple data.
  # @attr_reader [Hash] labels a Grom::Labels object generated from n-triple data.
  class Response
    attr_reader :objects, :labels

    # @param [Array] objects Grom::Node objects generated from n-triple data.
    # @param [Hash] labels a Grom::Labels object generated from n-triple data.
    def initialize(objects, labels = nil)
      @objects = objects
      @labels = labels
    end
  end
end
