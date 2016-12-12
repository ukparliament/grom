require 'grom'

module Grom
  module GraphMapper

    def get_graph_data(uri)
      RDF::Graph.load(uri, format: :ttl)
      # ttl_data = Net::HTTP.get(URI(uri))
      # create_graph_from_ttl(ttl_data)
    end

    def convert_to_ttl(data)
      result = ""
      data.each_statement do |statement|
        result << RDF::NTriples::Writer.serialize(statement)
      end
      result
    end

    def create_graph_from_ttl(ttl_data)
      # graph = RDF::Graph.new
      # RDF::Turtle::Reader.new(ttl_data) do |reader|
      #   reader.each_statement do |statement|
      #     graph << statement
      #   end
      # end
      # graph
      RDF::Graph.load(ttl_data, format: :ttl)
    end

    def get_id(uri)
      uri == RDF.type.to_s ? 'type' : uri.to_s.split("/").last
    end

    def statements_mapper(graph)
      hash = {}
      graph.each_statement do |s|
        subject = get_id(s.subject)
        hash[subject] ||= { :id => subject, :graph => RDF::Graph.new }
        hash[subject][:graph] << s
        hash[subject] ||= { :id => subject }
        hash[subject][get_id(s.predicate).to_sym] = s.object.to_s
      end
      hash.values
    end

    def through_split_graph(graph)
      associated_hash, through_hash = {}, {}
      graph.each_statement do |s|
        if (s.subject.to_s =~ URI::regexp) == 0
          subject = get_id(s.subject)
          associated_hash[subject] ||= { :id => subject, :graph => RDF::Graph.new }
          associated_hash[subject][:graph] << s
          associated_hash[subject][get_id(s.predicate).to_sym] = s.object.to_s
        else
          through_hash[s.subject.to_s] ||= {}
          if get_id(s.predicate) == "connect"
            through_hash[s.subject.to_s][:associated_object_id] = get_id(s.object)
          elsif get_id(s.predicate) == "objectId"
            through_hash[s.subject.to_s][:id] = get_id(s.object)
          else
            through_hash[s.subject.to_s][get_id(s.predicate).to_sym] = s.object.to_s
          end
        end
      end
      { associated_class_hash: associated_hash, through_class_hash: through_hash }
    end

  end
end