module Grom
  module Helper
    def self.pluralize_instance_variable_symbol(string)
      string = ActiveSupport::Inflector.underscore(string)
      string = ActiveSupport::Inflector.pluralize(string).downcase

      "@#{string}".to_sym
    end

    def self.lazy_array_insert(hash, key, value)
      hash[key] ||= []
      hash[key] << value
    end

    def self.get_id(uri)
      return nil if uri.to_s['/'].nil?

      uri == RDF.type.to_s ? 'type' : uri.to_s.split('/').last
    end
  end
end
