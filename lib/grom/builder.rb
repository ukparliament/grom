module Grom
  # Builds Grom::Node objects from a Grom::Reader instance.
  #
  # @since 0.1.0
  # @attr_reader [Array] objects Grom::Node objects generated from n-triple data.
  class Builder
    attr_reader :objects

    # @param [Grom::Reader] reader a Grom::Reader instance populated with data.
    # @param [Module] decorators a Module that answers to #decorate_with_type(node, type)
    def initialize(reader, decorators = nil)
      @reader = reader
      @decorators = decorators

      build_objects
    end

    # Builds and links Grom::Node objects from n-triple data.
    #
    # @return [Array] array of linked Grom::Node objects.
    def build_objects
      build_objects_by_subject
      link_objects

      @objects
    end

    # Builds Grom::Node objects from n-triple data grouping by their subject.
    #
    # @return [Grom::Builder] an instance of self.
    def build_objects_by_subject
      @objects = []
      @objects_by_subject = {}

      @reader.statements_by_subject.each do |subject, statements|
        object = Grom::Node.new(statements, @decorators)
        @objects_by_subject[subject] = object
        @objects << object
      end

      self
    end

    # Links Grom::Node objects together by predicate and object.
    #
    # @return [Grom::Builder] an instance of self.
    def link_objects
      @reader.edges_by_subject.each do |subject, predicates|
        predicates.each do |predicate, object_uris|
          raise NamingError if predicate == 'type'

          current_node = @objects_by_subject[subject]
          next if current_node.nil?

          object_uris.each do |object_uri|
            predicate_name_symbol = "@#{predicate}".to_sym

            # Get the current value (if there is one)
            current_value = current_node.instance_variable_get(predicate_name_symbol)

            object = current_value

            # If we have stored a string, and there are objects to link, create an empty array
            current_value_is_string    = current_value.is_a?(String)
            object_is_array_of_strings = object.all? { |entry| entry.is_a?(String) } if object.is_a?(Array)
            object_by_uri              = @objects_by_subject[object_uri]

            object = [] if (current_value_is_string || object_is_array_of_strings) && object_by_uri

            # If the above is correct, and we have an array
            if object.is_a?(Array)
              # Insert the current value (only if this is a new array (prevents possible duplication),
              # the current value is a string, and there are no linked objects to insert)
              object << current_value if object.empty? && current_value_is_string && object_by_uri.nil?

              # Insert linked objects, if there are any
              object << object_by_uri if object_by_uri
            end

            current_node.instance_variable_set(predicate_name_symbol, object)
          end
        end
      end

      self
    end
  end
end
