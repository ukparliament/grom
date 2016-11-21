require 'grom'

module Grom
  module Helpers

    def url_builder(owner_object, associated_class_name, options={})
      id = owner_object.id
      owner_class_name_plural = create_plural_property_name(owner_object.class.name)
      associated_class_name = options[:single].nil? ? create_plural_property_name(associated_class_name) : create_property_name(associated_class_name)
      # associated_class_name = create_plural_property_name(associated_class_name) if options[:single].nil?
      endpoint = "#{API_ENDPOINT}/#{owner_class_name_plural}/#{id}/#{associated_class_name}"
      endpoint += options[:optional].nil? ? '.ttl' : "/#{options[:optional]}.ttl"
    end

    def create_class_name(plural_name)
      ActiveSupport::Inflector.camelize(ActiveSupport::Inflector.singularize(plural_name.to_s).capitalize)
    end

    def create_plural_property_name(class_name)
      ActiveSupport::Inflector.pluralize(create_property_name(class_name))
    end

    def create_property_name(class_name)
      ActiveSupport::Inflector.underscore(class_name).downcase
    end
  end
end