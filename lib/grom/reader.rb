module Grom
  # Reads n-triple data and passes it to a Grom::Builder instance to create objects
  #
  # @since 0.1.0
  # @attr_reader [String] data n-triple data.
  # @attr_reader [Hash] statements_by_subject statements grouped by subject.
  # @attr_reader [Hash] edges_by_subject subjects connected to objects which are uris via their predicates.
  # @attr_reader [Grom::Response] response object containing Grom::Node objects and a Grom::Labels object.
  # @attr_reader [Hash] labels_by_subject subjects connected to object which are their labels.
  class Reader
    attr_reader :data, :statements_by_subject, :edges_by_subject, :response, :labels_by_subject

    # @param [String] data n-triple data.
    # @param [Module] decorators decorators to use when building Grom::Node objects.
    def initialize(data, decorators = nil)
      @data = data

      read_data

      @response = Grom::Builder.new(self, decorators).response
    end

    # Reads the n-triple data and separates the statements by subject.
    #
    # @return [Grom::Reader] an instance of self.
    def read_data
      @statements_by_subject = {}
      @edges_by_subject = {}
      @labels_by_subject = {}

      RDF::NTriples::Reader.new(@data) do |reader|
        reader.each_statement do |statement|
          subject = statement.subject.to_s

          # separate statements which are labels from other the statements
          if statement.predicate == RDF::RDFS.label
            Grom::Helper.lazy_array_insert(@labels_by_subject, subject, statement.object)
          else
            Grom::Helper.lazy_array_insert(@statements_by_subject, subject, statement)
          end

          predicate = statement.predicate.to_s

          object_is_possible_link = statement.object.uri? || statement.object.is_a?(RDF::Node)
          predicate_is_not_a_type_definition = predicate != RDF.type.to_s

          if object_is_possible_link && predicate_is_not_a_type_definition
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
