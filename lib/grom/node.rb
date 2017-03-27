module Grom
  # A Ruby object populated with n-triple data.
  #
  # @since 0.1.0
  # @attr_reader [Array] statements an array of n-triple statements.
  class Node
    BLANK = 'blank_node'.freeze

    attr_reader :statements

    # @param [Array] statements an array of n-triple statements.
    def initialize(statements)
      @statements = statements

      populate
    end

    # Allows the user to access instance variables as methods or raise an error if the variable is not defined.
    #
    # @param [Symbol] method name of method.
    # @param [Array] *params extra arguments to pass to super.
    # @param [Block] &block block to pass to super.
    # @example Accessing instance variables populated from statements
    #   statements = [
    #      RDF::Statement.new(RDF::URI.new('http://example.com/123'), RDF.type, 'Person'),
    #      RDF::Statement.new(RDF::URI.new('http://example.com/123'), RDF::URI.new('http://example.com/forename'), 'Jane'),
    #      RDF::Statement.new(RDF::URI.new('http://example.com/123'), RDF::URI.new('http://example.com/surname'), 'Smith')
    #   ]
    #
    #   node = Grom::Node.new(statements)
    #
    #   node.forename #=> 'Jane'
    #
    # @example Accessing instance variables created on the fly
    #   statements = [RDF::Statement.new(RDF::URI.new('http://example.com/123'), RDF.type, 'Person')]
    #
    #   node = Grom::Node.new(statements)
    #   node.instance_variable_set('@foo', 'bar')
    #
    #   node.foo #=> 'bar'
    #
    # @raise [NoMethodError] raises error if the method does not exist.
    def method_missing(method, *params, &block)
      instance_variable_get("@#{method}".to_sym) || super
    end

    # Allows the user to check if a Grom::Node responds to an instance variable
    #
    # @param [Symbol] method name of method.
    # @param [Boolean] include_all indicates whether to include private and protected methods (defaults to false).
    # @example Using respond_to?
    #
    #   statements = [
    #      RDF::Statement.new(RDF::URI.new('http://example.com/123'), RDF.type, 'Person'),
    #      RDF::Statement.new(RDF::URI.new('http://example.com/123'), RDF::URI.new('http://example.com/forename'), 'Jane'),
    #      RDF::Statement.new(RDF::URI.new('http://example.com/123'), RDF::URI.new('http://example.com/surname'), 'Smith')
    #   ]

    #   node = Grom::Node.new(statements)
    #
    #   node.respond_to?(:forename) #=> 'Jane'
    #   node.respond_to?(:foo) #=> false
    def respond_to_missing?(method, include_all = false)
      instance_variable_get("@#{method}".to_sym) || super
    end

    # Checks if Grom::Node is a blank node
    #
    # @return [Boolean] a boolean depending on whether or not the Grom::Node is a blank node
    def blank?
      @statements.first.subject.anonymous?
    end

    private

    def set_graph_id
      graph_id = Grom::Helper.get_id(@statements.first.subject)
      instance_variable_set('@graph_id'.to_sym, graph_id)
    end

    def populate
      set_graph_id
      @statements.each do |statement|
        attribute_name = Grom::Helper.get_id(statement.predicate)
        attribute_value = statement.object.to_s
        instance_variable_set("@#{attribute_name}".to_sym, attribute_value)
      end
    end
  end
end
