require 'grom'
require 'rdf/turtle'

module Grom
  module GraphMapper

    def get_ttl_data(uri)
      Net::HTTP.get(URI(uri))
    end

    def get_id(uri)
      uri == RDF.type.to_s ? 'type' : uri.to_s.split("/").last
    end

    def create_hash_from_ttl(ttl_data)
      hash = {}
      RDF::Turtle::Reader.new(ttl_data) do |reader|
        reader.each_statement do |statement|
          statement_mapper(statement, hash)
        end
      end
      hash.values
    end

    def statement_mapper(statement, hash)
      subject = get_id(statement.subject)
      hash[subject] ||= { :id => subject }
      hash[subject][get_id(statement.predicate).to_sym] = statement.object.to_s
    end

    def statements_with_mapper(ttl_data)
      hash = {}
      RDF::Turtle::Reader.new(ttl_data) do |reader|
        reader.each_statement do |statement|
          subject = get_id(statement.subject)
          hash[subject] ||= {:id => subject}
          predicate = get_id(statement.predicate)
          if (predicate == "connect")
            (hash[subject][predicate.to_sym] ||= []) << get_id(statement.object.to_s)
          else
            hash[subject][predicate.to_sym] = statement.object.to_s
          end
        end
      end
      hash.values
    end

    def through_split_graph(ttl_data)
      associated_hash, through_hash = {}, {}
      RDF::Turtle::Reader.new(ttl_data) do |reader|
        reader.each_statement do |s|
          if (s.subject.to_s =~ URI::regexp) == 0
            subject = get_id(s.subject)
            associated_hash[subject] ||= { :id => subject }
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
      end

      { associated_class_hash: associated_hash, through_class_hash: through_hash }
    end

  end
end