require 'grom'
require 'net/http'

module Grom
  module GraphMapper

    def get_graph_data(uri)
      ttl_data = Net::HTTP.get(URI(uri))
      create_graph_from_ttl(ttl_data)
    end

    def convert_to_ttl(data)
      # p "called convert_to_ttl"
      result = ""
      data.each_statement do |statement|
        result << RDF::NTriples::Writer.serialize(statement)
      end
      result
    end

    def create_graph_from_ttl(ttl_data)
      # p "called create_graph_from_ttl"
      # p ttl_data
      ttl_data
      graph = RDF::Graph.new
      RDF::NTriples::Reader.new(ttl_data) do |reader|
        reader.each_statement do |statement|
          graph << statement
        end
      end
      graph
    end

    def get_id(uri)
      uri == RDF.type.to_s ? 'type' : uri.to_s.split("/").last
    end

    def get_object_and_predicate(statement)
      predicate = get_id(statement.predicate)
      { predicate.to_sym => statement.object.to_s }
    end

    def statements_mapper_by_subject(graph)
      graph.subjects.map do |subject|
        individual_graph = RDF::Graph.new
        pattern = RDF::Query::Pattern.new(subject, :predicate, :object)
        attributes = graph.query(pattern).map do |statement|
          individual_graph << statement
          get_object_and_predicate(statement)
        end.reduce({}, :merge)

        attributes.merge({id: get_id(subject), graph: individual_graph })
      end
    end

    def split_by_subject(graph, associated_class_name)
      associated_class_type_pattern = RDF::Query::Pattern.new(:subject, RDF.type, RDF::URI.new("#{DATA_URI_PREFIX}/schema/#{associated_class_name}"))
      associated_graph = RDF::Graph.new
      through_graph = RDF::Graph.new
      graph.query(associated_class_type_pattern).subjects.map do |subject|
        subject_pattern = RDF::Query::Pattern.new(subject, :predicate, :object)
        graph.query(subject_pattern).each do |statement|
          associated_graph << statement
        end
        through_graph << graph
        through_graph.delete(associated_graph)
      end
      { through_graph: through_graph, associated_class_graph: associated_graph }
    end

    def get_through_graphs(graph, id)
      connection_pattern = RDF::Query::Pattern.new(:subject, :predicate, RDF::URI.new("#{DATA_URI_PREFIX}/#{id}"))
      graph.query(connection_pattern).subjects.map do |subject|
        subject_pattern = RDF::Query::Pattern.new(subject, :predicate, :object)
        graph.query(subject_pattern)
      end
     end

  end
end