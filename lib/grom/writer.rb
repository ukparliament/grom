module Grom
  class Writer

    def initialize(reader)
      @reader = reader
    end

    def initialize_objects_hashes
      @objects, @objects_by_subject = [], {}
    end

    def create_objects_by_subject
      initialize_objects_hashes
      @reader.subjects_by_type.each do |_type, subjects|
        subjects.each do |subject|
          begin
            object = Grom::Node.new(@reader.statements_by_subject[subject])
            @objects_by_subject[subject] = object
            @objects << object
          rescue NoMethodError
            p 'No statements passed to Grom::Node.new'
          end
        end
      end

      self
    end

    def link_objects
      @reader.connections_by_subject.each do |subject, connections|
        current_node = @objects_by_subject[subject]
        connections.each do |connection_subject|
          begin
            connection_node = @objects_by_subject[connection_subject]
            current_node_type = Grom::Reader.get_id(current_node.type)
            connector_name_symbol = Grom::Helper.pluralize_instance_variable_symbol(current_node_type)

            connected_object_array = connection_node.instance_variable_get(connector_name_symbol)
            connected_object_array = [] if connected_object_array.nil?
            connected_object_array << current_node

            connection_node.instance_variable_set(connector_name_symbol, connected_object_array)
          rescue Exceptions => e
            p e.inspect
            p 'Grom::Reader.get_id has returned nil'
          end
        end
      end

      self
    end
  end
end
