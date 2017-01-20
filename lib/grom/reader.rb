require 'pry'

module Grom
  class Reader
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def create_hashes
      # Reset all our hashes just in case
      @statements_by_subject  = {}
      @subjects_by_type       = {}
      @connections_by_subject = {}

      RDF::NTriples::Reader.new(@data) do |reader|
        reader.each_statement do |statement|
          subject = statement.subject.to_s
          Grom::Helper.lazy_array_insert(@statements_by_subject, subject, statement)

          predicate = statement.predicate.to_s

          # is this statement a type definition?
          if predicate == RDF.type.to_s
            Grom::Helper.lazy_array_insert(@subjects_by_type, Grom::Reader.get_id(statement.object), subject)
          end

          if (statement.object =~ URI::regexp) == 0 && predicate != RDF.type.to_s
            Grom::Helper.lazy_array_insert(@connections_by_subject, subject, statement.object.to_s)
          end
        end
      end

      self
    end

    def initialize_objects_hashes
      @objects, @objects_by_subject = [], {}
    end

    def create_objects_by_subject
      initialize_objects_hashes
      @subjects_by_type.each do |_type, subjects|
        subjects.each do |subject|
          begin
            object = Grom::Node.new(@statements_by_subject[subject])
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
      @connections_by_subject.each do |subject, connections|
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

    def self.get_id(uri)
      return nil if uri.to_s['/'].nil?

      uri == RDF.type.to_s ? 'type' : uri.to_s.split('/').last
    end
  end
end
