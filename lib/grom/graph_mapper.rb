require 'grom'

module Grom
  module GraphMapper

    def get_graph_data(uri)
      ttl_data = Net::HTTP.get(URI(uri))
      create_graph_from_ttl(ttl_data)
    end

    def convert_to_ttl(data)
      result = ""
      data.each_statement do |statement|
        result << RDF::NTriples::Writer.serialize(statement)
      end
      result
    end

    def create_graph_from_ttl(ttl_data)
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

    def statements_mapper(graph)
      hash = {}
      graph.each_statement do |s|
        subject = get_id(s.subject)
        # hash[subject] ||= { :id => subject, :graph => RDF::Graph.new }
        # hash[subject][:graph] << s
        hash[subject] ||= { :id => subject }
        hash[subject][get_id(s.predicate).to_sym] = s.object.to_s
      end
      hash.values
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