module Grom
  # A Ruby object populated with n-triple data for labels.
  #
  # Delegates a number of common methods to the hash of Grom::Labels including, but not limited to, :size, :each, etc.
  #
  # @attr_reader [Hash] labels a hash of n-triple label data grouped by subject.
  class Labels
    extend Forwardable
    attr_reader :labels
    def_delegators :@labels, :size, :each, :select, :select!, :length, :empty?

    # @param [Hash] labels a hash of n-triple label data grouped by subject.
    def initialize(labels)
      @labels = labels
    end

    # Fetchs the label for a given property.
    #
    # @param [Symbol] property the property we require a label for.
    # @param [String] default the default string value to use if the given property does not have a label.
    #
    # @example Where a property has a label:
    #   labels = { 'https://id.parliament.uk/schema/layingDate'      => ['laying date'],
    #       'https://id.parliament.uk/schema/personGivenName'        => ['person given name'],
    #       'https://id.parliament.uk/schema/procedureName'          => ['procedure name']
    #   }
    #
    #   labels_class = Labels.new(labels)
    #
    #   labels_class.fetch(:layingDate, 'date') #=> 'laying date'
    #
    # @example Where a property does not have a label:
    #
    #   labels = { 'https://id.parliament.uk/schema/layingDate'      => ['laying date'],
    #       'https://id.parliament.uk/schema/personGivenName'        => ['person given name'],
    #       'https://id.parliament.uk/schema/procedureName'          => ['procedure name']
    #   }
    #
    #   labels_class = Labels.new(labels)
    #
    #   labels_class.fetch(:workPackageName, 'name') #=> 'name'
    #
    # @return [Boolean] a boolean depending on whether or not the Grom::Node is a blank node.
    def fetch(property, default)
      label = labels.select do |subject|
        Grom::Helper.get_id(subject) == property.to_s
      end

      label_value = label.values.flatten.first.to_s

      label.empty? ? default : label_value
    end
  end
end
