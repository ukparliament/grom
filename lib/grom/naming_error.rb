module Grom
  # Namespace for errors.
  class NamingError < StandardError
    def initialize
      super("'type' is reserved for RDF type and cannot be used as a predicate name.")
    end
  end
end
