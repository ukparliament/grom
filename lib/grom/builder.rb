module Grom
  # Builds Grom::Node objects from a Grom::Reader instance.
  #
  # @since 0.1.0
  # @attr_reader [Array] objects Grom::Node objects generated from n-triple data.
  class Builder
    attr_reader :objects

    # @param [Grom::Reader] reader a Grom::Reader instance populated with data.
    def initialize(reader)
      @reader = reader

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
        object = Grom::Node.new(statements)
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
          current_node = @objects_by_subject[subject]

          object_uris.each do |object_uri|
            predicate_name_symbol = "@#{predicate}".to_sym
            object_array = current_node.instance_variable_get(predicate_name_symbol)
            object_array = [] if object_array.is_a?(String)
            object_array << @objects_by_subject[object_uri]

            current_node.instance_variable_set(predicate_name_symbol, object_array)
          end
        end
      end

      self
    end
  end
end
