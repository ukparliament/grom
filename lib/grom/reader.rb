module Grom
  class Reader
    attr_reader :data, :statements_by_subject, :subjects_by_type, :edges_by_subject, :objects

    def initialize(data)
      @data = data

      read_data

      @objects = Grom::Builder.new(self).objects
    end

    def read_data
      # Reset all our hashes just in case
      @statements_by_subject  = {}

      # TODO: Find a better name for this hash!
      @edges_by_subject = {}

      RDF::NTriples::Reader.new(@data) do |reader|
        reader.each_statement do |statement|
          subject = statement.subject.to_s

          # TODO: Use Ruby key value syntax in below method.
          Grom::Helper.lazy_array_insert(@statements_by_subject, subject, statement)

          predicate = statement.predicate.to_s

          if statement.object.uri? && predicate != RDF.type.to_s
            predicate = Grom::Helper.get_id(predicate)
            @edges_by_subject[subject] ||= {}
            @edges_by_subject[subject][predicate] ||= []
            @edges_by_subject[subject][predicate] << statement.object.to_s
          end
        end
      end

      self
    end
  end
end
