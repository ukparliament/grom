module Grom
  class Builder
    attr_reader :objects

    def initialize(reader)
      @reader = reader

      build_objects
    end

    def build_objects
      build_objects_by_subject
      link_objects

      @objects
    end

    def initialize_objects_hashes
      @objects, @objects_by_subject = [], {}
    end

    def build_objects_by_subject
      initialize_objects_hashes
      @reader.statements_by_subject.each do |subject, statements|
        object = Grom::Node.new(statements)
        @objects_by_subject[subject] = object
        @objects << object
      end

      self
    end

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

            # TODO: Not sure about the above conditional
          end
        end
      end

      self
    end
  end
end
